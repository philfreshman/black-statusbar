import Foundation
import Testing
@testable import NightbarCore

@MainActor
struct UpdateModelTests {
    private let current = AppVersion("1.0.0")!
    private let release = Release(
        version: AppVersion("1.1.0")!,
        pageURL: URL(string: "https://github.com/philfreshman/nightbar/releases/tag/v1.1.0")!,
        downloadURL: URL(string: "https://github.com/philfreshman/nightbar/releases/download/v1.1.0/Nightbar.zip")!
    )

    @Test func startsChecking() {
        let model = makeModel(checkResult: .success(.upToDate(latest: release)))

        #expect(model.state == .checking)
    }

    @Test func checkFindsAppUpToDate() async {
        let model = makeModel(checkResult: .success(.upToDate(latest: release)))

        await model.check()

        #expect(model.state == .upToDate(latest: release))
        #expect(model.latestRelease == release)
    }

    @Test func checkFindsUpdate() async {
        let model = makeModel(checkResult: .success(.updateAvailable(release)))

        await model.check()

        #expect(model.state == .updateAvailable(release))
        #expect(model.latestRelease == release)
    }

    @Test func failedCheckShowsError() async {
        let model = makeModel(checkResult: .failure(FakeError()))

        await model.check()

        #expect(model.state == .failed(message: FakeError.message))
        #expect(model.latestRelease == nil)
    }

    @Test func installingUpdateEndsInstalled() async {
        let model = makeModel(checkResult: .success(.updateAvailable(release)))
        await model.check()

        await model.installUpdate()

        #expect(model.state == .installed(release))
    }

    @Test func failedInstallShowsError() async {
        let model = makeModel(checkResult: .success(.updateAvailable(release)), installError: FakeError())
        await model.check()

        await model.installUpdate()

        #expect(model.state == .failed(message: FakeError.message))
        #expect(model.latestRelease == release)
    }

    @Test func installDoesNothingWithoutUpdate() async {
        let model = makeModel(checkResult: .success(.upToDate(latest: release)))
        await model.check()

        await model.installUpdate()

        #expect(model.state == .upToDate(latest: release))
    }

    @Test func checkIsIgnoredWhileInstalling() async {
        let (gate, opener) = AsyncStream<Void>.makeStream()
        let model = makeModel(checkResult: .success(.updateAvailable(release)), installGate: gate)
        await model.check()

        let install = Task { await model.installUpdate() }
        while model.state != .installing(release) {
            await Task.yield()
        }
        await model.check()
        #expect(model.state == .installing(release))

        opener.finish()
        await install.value
        #expect(model.state == .installed(release))
    }

    @Test func checkIsIgnoredOnceInstalled() async {
        let model = makeModel(checkResult: .success(.updateAvailable(release)))
        await model.check()
        await model.installUpdate()

        await model.check()

        #expect(model.state == .installed(release))
    }

    @Test func relaunchGoesToInstaller() {
        let relaunches = RelaunchCounter()
        let model = UpdateModel(
            currentVersion: current,
            checker: FakeChecker(result: .success(.updateAvailable(release))),
            installer: FakeInstaller(relaunches: relaunches)
        )

        model.relaunch()

        #expect(relaunches.count == 1)
    }

    @Test func primaryActionFollowsState() {
        #expect(UpdatePrimaryAction(state: .checking) == .waiting)
        #expect(UpdatePrimaryAction(state: .upToDate(latest: release)) == .waiting)
        #expect(UpdatePrimaryAction(state: .updateAvailable(release)) == .update)
        #expect(UpdatePrimaryAction(state: .installing(release)) == .updating)
        #expect(UpdatePrimaryAction(state: .installed(release)) == .restart)
        #expect(UpdatePrimaryAction(state: .failed(message: "")) == .tryAgain)
    }

    @Test func onlyUpdateRestartAndRetryAreEnabled() {
        #expect(!UpdatePrimaryAction.waiting.isEnabled)
        #expect(!UpdatePrimaryAction.updating.isEnabled)
        #expect(UpdatePrimaryAction.update.isEnabled)
        #expect(UpdatePrimaryAction.restart.isEnabled)
        #expect(UpdatePrimaryAction.tryAgain.isEnabled)
    }

    private func makeModel(
        checkResult: Result<UpdateCheckResult, Error>,
        installError: Error? = nil,
        installGate: AsyncStream<Void>? = nil
    ) -> UpdateModel {
        UpdateModel(
            currentVersion: current,
            checker: FakeChecker(result: checkResult),
            installer: FakeInstaller(error: installError, gate: installGate)
        )
    }
}

private struct FakeError: LocalizedError {
    static let message = "The network is offline."
    var errorDescription: String? { Self.message }
}

/// Answers every check with the same result.
private struct FakeChecker: UpdateChecking {
    let result: Result<UpdateCheckResult, Error>

    func checkForUpdate(current: AppVersion?) async throws -> UpdateCheckResult {
        try result.get()
    }
}

/// Counts relaunches, so a test can see the model asked for one.
@MainActor
private final class RelaunchCounter {
    var count = 0
}

/// Installs nothing. Fails with `error` when given one, and waits for `gate` to finish when given one.
private struct FakeInstaller: UpdateInstalling {
    var error: Error?
    var gate: AsyncStream<Void>?
    var relaunches: RelaunchCounter?

    func install(_ release: Release) async throws {
        if let gate {
            for await _ in gate {}
        }
        if let error { throw error }
    }

    @MainActor func relaunch() {
        relaunches?.count += 1
    }
}

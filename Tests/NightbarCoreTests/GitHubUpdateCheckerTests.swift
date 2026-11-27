import Foundation
import Testing

@testable import NightbarCore

struct GitHubUpdateCheckerTests {
    private static let releaseJSON = """
        {"tag_name":"v0.2.0","html_url":"https://github.com/philfreshman/nightbar/releases/tag/v0.2.0",\
        "assets":[{"name":"Nightbar.zip","browser_download_url":\
        "https://github.com/philfreshman/nightbar/releases/download/v0.2.0/Nightbar.zip"}]}
        """

    private static let latest = Release(
        version: AppVersion("0.2.0")!,
        pageURL: URL(string: "https://github.com/philfreshman/nightbar/releases/tag/v0.2.0")!,
        downloadURL: URL(string: "https://github.com/philfreshman/nightbar/releases/download/v0.2.0/Nightbar.zip")!
    )

    private func checker(json: String = releaseJSON, status: Int = 200) -> GitHubUpdateChecker {
        GitHubUpdateChecker { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
            return (Data(json.utf8), response)
        }
    }

    @Test func offersANewerRelease() async throws {
        let result = try await checker().checkForUpdate(current: AppVersion("0.1.0"))

        #expect(result == .updateAvailable(Self.latest))
    }

    @Test(arguments: ["0.2.0", "0.3.0"])
    func isUpToDateOnTheSameOrALaterVersion(current: String) async throws {
        let result = try await checker().checkForUpdate(current: AppVersion(current))

        #expect(result == .upToDate(latest: Self.latest))
    }

    @Test func offersTheReleaseWhenTheCurrentVersionIsUnknown() async throws {
        let result = try await checker().checkForUpdate(current: nil)

        #expect(result == .updateAvailable(Self.latest))
    }

    @Test func failsWhenTheReleaseHasNoZip() async {
        let json = Self.releaseJSON.replacingOccurrences(of: "\"Nightbar.zip\"", with: "\"Other.zip\"")

        await #expect(throws: UpdateError.missingDownload) {
            try await checker(json: json).checkForUpdate(current: nil)
        }
    }

    @Test func failsWhenTheTagIsNotAVersion() async {
        let json = Self.releaseJSON.replacingOccurrences(of: "\"v0.2.0\"", with: "\"nightly\"")

        await #expect(throws: UpdateError.invalidVersionTag("nightly")) {
            try await checker(json: json).checkForUpdate(current: nil)
        }
    }

    @Test func failsOnAnUnreadableResponse() async {
        await #expect(throws: UpdateError.unreadableResponse) {
            try await checker(json: "<html>").checkForUpdate(current: nil)
        }
    }

    @Test(arguments: [403, 500])
    func failsWhenGitHubAnswersWithAnError(status: Int) async {
        await #expect(throws: UpdateError.gitHubUnavailable(statusCode: status)) {
            try await checker(status: status).checkForUpdate(current: nil)
        }
    }

    @Test func explainsRateLimitsDifferentlyFromOtherErrors() {
        let rateLimited = UpdateError.gitHubUnavailable(statusCode: 403).errorDescription
        let serverError = UpdateError.gitHubUnavailable(statusCode: 500).errorDescription

        #expect(rateLimited != serverError)
        #expect(serverError?.contains("500") == true)
    }

    @Test func asksGitHubForTheLatestReleaseAsJSON() async throws {
        let sent = SentRequests()
        let checker = GitHubUpdateChecker { request in
            sent.append(request)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (Data(Self.releaseJSON.utf8), response)
        }

        _ = try await checker.checkForUpdate(current: nil)

        let request = try #require(sent.all.first)
        #expect(sent.all.count == 1)
        #expect(request.url == NightbarLinks.latestReleaseAPI)
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/vnd.github+json")
        #expect(request.value(forHTTPHeaderField: "User-Agent") == "Nightbar")
    }
}

/// Keeps the requests a fake fetch received, so a test can look at them afterwards.
private final class SentRequests: @unchecked Sendable {
    private let lock = NSLock()
    private var requests: [URLRequest] = []

    var all: [URLRequest] {
        lock.withLock { requests }
    }

    func append(_ request: URLRequest) {
        lock.withLock { requests.append(request) }
    }
}

import SwiftUI

/// The content of the update window: the app and its version, what the update check found,
/// one button for the next step, and links to the project on GitHub.
struct UpdateView: View {
    let model: UpdateModel

    var body: some View {
        VStack(spacing: 14) {
            header
            UpdateStatusLine(state: model.state)
            primaryButton
            links
        }
        .padding(20)
        .frame(width: 300)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var header: some View {
        VStack(spacing: 4) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)
            Text("Nightbar")
                .font(.headline)
            Text(versionText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var versionText: String {
        model.currentVersion.map { "Version \($0)" } ?? "Version unknown"
    }

    private var primaryButton: some View {
        let action = UpdatePrimaryAction(state: model.state)
        return Button(action.title) { perform(action) }
            .disabled(!action.isEnabled)
            .keyboardShortcut(.defaultAction)
            .controlSize(.large)
    }

    private func perform(_ action: UpdatePrimaryAction) {
        switch action {
        case .update: Task { await model.installUpdate() }
        case .restart: model.relaunch()
        case .tryAgain: Task { await model.check() }
        case .waiting, .updating: break
        }
    }

    private var links: some View {
        HStack(spacing: 16) {
            Link("GitHub", destination: NightbarLinks.repository)
            Link("Release Notes", destination: model.latestRelease?.pageURL ?? NightbarLinks.releases)
        }
        .font(.footnote)
    }
}

/// One line saying what the update window is doing or found.
private struct UpdateStatusLine: View {
    let state: UpdateModel.State

    var body: some View {
        Group {
            switch state {
            case .checking:
                progress("Checking for updates…")
            case .upToDate:
                Label("You're up to date.", systemImage: "checkmark.circle.fill")
                    .symbolRenderingMode(.multicolor)
            case .updateAvailable(let release):
                Text("Nightbar \(release.version.description) is available.")
            case .installing(let release):
                progress("Installing Nightbar \(release.version.description)…")
            case .installed(let release):
                Text("Nightbar \(release.version.description) is installed. Restart to use it.")
            case .failed(let message):
                Text(message)
                    .foregroundStyle(.red)
            }
        }
        .font(.callout)
        .multilineTextAlignment(.center)
        .frame(minHeight: 20)
    }

    private func progress(_ title: String) -> some View {
        HStack(spacing: 8) {
            ProgressView()
                .controlSize(.small)
            Text(title)
        }
    }
}

/// What the update window's one button does in each state.
enum UpdatePrimaryAction: Equatable {
    case waiting
    case update
    case updating
    case restart
    case tryAgain

    init(state: UpdateModel.State) {
        switch state {
        case .checking, .upToDate: self = .waiting
        case .updateAvailable: self = .update
        case .installing: self = .updating
        case .installed: self = .restart
        case .failed: self = .tryAgain
        }
    }

    var title: String {
        switch self {
        case .waiting, .update: "Update"
        case .updating: "Updating…"
        case .restart: "Restart Nightbar"
        case .tryAgain: "Try Again"
        }
    }

    var isEnabled: Bool {
        switch self {
        case .update, .restart, .tryAgain: true
        case .waiting, .updating: false
        }
    }
}

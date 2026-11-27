import Foundation

/// Checks for updates by asking the GitHub API for Nightbar's latest release.
struct GitHubUpdateChecker: UpdateChecking {
    typealias Fetch = @Sendable (URLRequest) async throws -> (Data, URLResponse)

    /// The release asset that holds the zipped app.
    static let assetName = "Nightbar.zip"

    private let fetch: Fetch

    /// `fetch` sends the request; tests pass a fake one instead of the network.
    init(fetch: @escaping Fetch = { try await URLSession.shared.data(for: $0) }) {
        self.fetch = fetch
    }

    func checkForUpdate(current: AppVersion?) async throws -> UpdateCheckResult {
        let latest = try await latestRelease()
        guard let current, current >= latest.version else { return .updateAvailable(latest) }
        return .upToDate(latest: latest)
    }

    /// The request for the latest release, with the headers GitHub asks API clients to send.
    private static var latestReleaseRequest: URLRequest {
        var request = URLRequest(url: NightbarLinks.latestReleaseAPI)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Nightbar", forHTTPHeaderField: "User-Agent")
        return request
    }

    private func latestRelease() async throws -> Release {
        let (data, response) = try await fetch(Self.latestReleaseRequest)
        try Self.checkStatus(of: response)
        return try Self.release(from: data)
    }

    private static func checkStatus(of response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { throw UpdateError.unreadableResponse }
        guard (200...299).contains(http.statusCode) else {
            throw UpdateError.gitHubUnavailable(statusCode: http.statusCode)
        }
    }

    private static func release(from data: Data) throws -> Release {
        guard let payload = try? JSONDecoder().decode(GitHubRelease.self, from: data) else {
            throw UpdateError.unreadableResponse
        }
        guard let version = AppVersion(payload.tagName) else {
            throw UpdateError.invalidVersionTag(payload.tagName)
        }
        guard let asset = payload.assets.first(where: { $0.name == assetName }) else {
            throw UpdateError.missingDownload
        }
        return Release(version: version, pageURL: payload.htmlURL, downloadURL: asset.downloadURL)
    }
}

/// The parts of GitHub's release JSON that Nightbar reads.
private struct GitHubRelease: Decodable {
    let tagName: String
    let htmlURL: URL
    let assets: [Asset]

    struct Asset: Decodable {
        let name: String
        let downloadURL: URL

        enum CodingKeys: String, CodingKey {
            case name
            case downloadURL = "browser_download_url"
        }
    }

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
        case assets
    }
}

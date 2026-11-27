import Testing

@testable import NightbarCore

struct AppVersionTests {
    @Test(arguments: ["0.2.0", "v0.2.0"])
    func readsVersionsWithAndWithoutLeadingV(text: String) {
        #expect(AppVersion(text)?.components == [0, 2, 0])
    }

    @Test(arguments: ["", "v", "1..2", "abc", "1.-2", "1.2.", "1.2.x"])
    func rejectsTextThatIsNotAVersion(text: String) {
        #expect(AppVersion(text) == nil)
    }

    @Test func comparesEachPartAsANumber() throws {
        #expect(try #require(AppVersion("0.2.0")) < #require(AppVersion("0.10.0")))
        #expect(try #require(AppVersion("0.1.2")) < #require(AppVersion("0.2.0")))
        #expect(try !(#require(AppVersion("1.0.0")) < #require(AppVersion("1.0.0"))))
    }

    @Test func treatsMissingPartsAsZero() throws {
        #expect(try #require(AppVersion("1.2")) == #require(AppVersion("1.2.0")))
        #expect(try #require(AppVersion("1.2")) < #require(AppVersion("1.2.1")))
    }

    @Test func describesItselfWithoutTheV() {
        #expect(AppVersion("v1.2.3")?.description == "1.2.3")
    }
}

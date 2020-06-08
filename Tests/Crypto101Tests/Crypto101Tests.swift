import XCTest
@testable import Crypto101

final class Crypto101Tests: XCTestCase {
    func testSHA256() {
        XCTAssertEqual(Crypto101.Hash.sha256("hello".data(using: .ascii)!).hex, "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    }

    static var allTests = [
        ("testSHA256", testSHA256),
    ]
}

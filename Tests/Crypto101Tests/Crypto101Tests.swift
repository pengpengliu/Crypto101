import XCTest
@testable import Crypto101

final class Crypto101Tests: XCTestCase {
    func testSHA256() {
        XCTAssertEqual(Crypto101.Hash.sha256("hello".data(using: .ascii)!).hex, "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    }
    
    func testECC() {
        let key = ECC.Key(priv: Array(Data(hex: "e580512c800c6de3bd5e65695b4cab739211b7ac41ffc2991b0cf75c4d3ccbdf")!))
        XCTAssertEqual(key.pub, Array(Data(hex: "0254dec37f0858dd993798f8b31ba912eb3cee803ac4209596cc79c804a2f3c201")!))
    }

    static var allTests = [
        ("testSHA256", testSHA256),
    ]
}

extension Data {
    init?(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hex.index(hex.startIndex, offsetBy: i * 2)
            let k = hex.index(j, offsetBy: 2)
            let bytes = hex[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
    
    var hex: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
}

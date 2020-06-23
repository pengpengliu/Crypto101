import XCTest
import CryptoSwift
@testable import Crypto101

final class Crypto101Tests: XCTestCase {
    func testSHA256() {
        XCTAssertEqual(Crypto101.Hash.sha256("hello".data(using: .ascii)!).toHexString(), "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    }
    
    func testRIPEMD() {
        let hash = Crypto101.Hash.ripemd160("Lorem ipsum dolor sit amet".data(using: .ascii)!)
        XCTAssertEqual(hash.toHexString(), "7d0982be59ebe828d02aa0d031aa6651644d60da")
        XCTAssertEqual(Crypto101.Hash.ripemd160("".data(using: .ascii)!).toHexString(), "9c1185a5c5e9fc54612808977ee8f548b2258d31")
    }
    
    func testECC() {
        let key = ECC.Key(priv: [UInt8](hex: "e580512c800c6de3bd5e65695b4cab739211b7ac41ffc2991b0cf75c4d3ccbdf"))
        XCTAssertEqual(key.pub.toHexString(), "0254dec37f0858dd993798f8b31ba912eb3cee803ac4209596cc79c804a2f3c201")
        // 54dec37f0858dd993798f8b31ba912eb3cee803ac4209596cc79c804a2f3c201c5c8c530ebd8af6cce71d1b2250dee29e660b1d10140226a7f5cbff46228de60
    }
    
    func testSign() {
        let hash: [UInt8] = Array(repeating: 1, count: 32)
        let key = ECC.Key(priv: [UInt8](hex: "e580512c800c6de3bd5e65695b4cab739211b7ac41ffc2991b0cf75c4d3ccbdf"))
        let signature = "304402203b63adb7a4d0f364269c7008cbb5647cbe825b3986ad7d245927ec2be78fed9102207cc0bcc62dd9add67d27c590e978d5777591e1d7e738e3b05844e968164041a3"
        XCTAssertEqual(Data(try key.sign(data: hash)).toHexString(), signature)
    }

    static var allTests = [
        ("testSHA256", testSHA256),
        ("testECC", testECC),
        ("testSign", testSign),
    ]
}

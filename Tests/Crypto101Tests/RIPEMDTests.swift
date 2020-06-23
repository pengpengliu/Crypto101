//
//  RIPEMDTests.swift
//  
//
//  Created by Liu Pengpeng on 2020/6/19.
//

import XCTest
import CryptoSwift
@testable import Crypto101

final class RIPEMDTests: XCTestCase {
    func testExample() {
        XCTAssertEqual(Crypto101.Hash.sha256("hello".data(using: .ascii)!).toHexString(), "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}

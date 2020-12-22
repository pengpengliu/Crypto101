//
//  Signature.swift
//  
//
//  Created by Liu Pengpeng on 2020/12/21.
//

import Foundation

public struct Signature {
    public var r: [UInt8]
    public var s: [UInt8]
    
    public var recoveryParam: UInt?
    
    public func toDER() -> [UInt8] {
        let lenR = r.count
        let lenS = s.count
        let length = 6 + lenR + lenS
        var der = [UInt8]()
        der.append(0x30)
        der.append(UInt8(length - 2))
        der.append(0x02)
        der.append(UInt8(lenR))
        der.append(contentsOf: r)
        der.append(0x02)
        der.append(UInt8(lenS))
        der.append(contentsOf: s)
        return der
    }
}

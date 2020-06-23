//
//  UInt32+CircularShift.swift
//  
//
//  Created by Liu Pengpeng on 2020/6/19.
//

import Foundation

precedencegroup ComparisonPrecedence {
  associativity: none
  higherThan: LogicalConjunctionPrecedence
}

// Circular left shift: http://en.wikipedia.org/wiki/Circular_shift
// Precendence should be the same as <<
// infix operator  ~<< { precedence 160 associativity none }
infix operator  ~<< : ComparisonPrecedence

//FIXME: Make framework-only once tests support it
public func ~<< (lhs: UInt32, rhs: Int) -> UInt32 {
    return (lhs << UInt32(rhs)) | (lhs >> UInt32(32 - rhs));
}

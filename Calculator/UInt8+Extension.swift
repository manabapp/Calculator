//
//  UInt8+Extension.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import Foundation

extension UInt8 {
    var char: Character {
        return Character(UnicodeScalar(self))
    }
}

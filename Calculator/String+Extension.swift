//
//  String+Extension.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import Foundation

extension String {
    var strReplace: String {
        guard let _ = try? NSRegularExpression(pattern: "^[\\d].[\\d]$", options: []) else {
            return self
        }

        guard let str = try? NSRegularExpression(pattern: "0+$", options: []) else {
            return self
        }
    
        var replacedStr: String = str.stringByReplacingMatches(in: self,
                                                               options: [],
                                                               range: NSMakeRange(0, self.count),
                                                               withTemplate: "")

        if replacedStr.hasSuffix(".") { replacedStr.removeLast() }

        return replacedStr
    }
    
    var round15: String {
        if !self.contains(".") {
            return self
        }
        let array: [String] = self.components(separatedBy: ".")
        if array.count != 2 {
            return self
        }
        if totalDigits <= 15 {
            return self
        }
        if (totalDigits - decimalDigits) >= 15 {
            return array[0]
        }
        return array[0] + "." + String(array[1].prefix(15 - totalDigits + decimalDigits))
    }

    var length: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
    
    func pregMatche(pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.length))
        return matches.count > 0
    }
    
    var isValidIPv4Format: Bool {
        self.pregMatche(pattern: "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$")
    }
    
    var isValidCidrFormat: Bool {
        self.pregMatche(pattern: "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/([0-9]|[1-2][0-9]|3[0-2])$")
    }
    
    var totalDigits: Int {
        var count = self.replacingOccurrences(of:",", with:"").count
//        var count = self.count
        if self.contains(".") {
            count -= 1
        }
        if self.contains("-") {
            count -= 1
        }
        return count
    }
    
    var decimalDigits: Int {
        let array: [String] = self.components(separatedBy: ".")
        if array.count != 2 {
            return 0
        }
        return array[1].count
    }
}

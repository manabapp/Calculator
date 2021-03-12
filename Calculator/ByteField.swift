//
//  ByteField.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI

struct ByteField: View {
    @EnvironmentObject var object: CalculatorSharedObject
    var byte: UInt8
    let label: String
    
    private var monospaceFontSize: CGFloat { Self.fontSize * 1.3 }
    static var fontSize: CGFloat = 11.3
    static var height1: CGFloat = 70.0
    static var height2: CGFloat = 105.0
    static let bitPattern = ["0000", "0001", "0010", "0011", "0100", "0101", "0110", "0111",
                             "1000", "1001", "1010", "1011", "1100", "1101", "1110", "1111"]
    
    static func initSize(width: CGFloat, height: CGFloat) {
        //Devices supported iOS 14 or newer
        switch width {
        case 428 ..< 1000: Self.fontSize = 12.5 //Device width 428pt : iPhone 12 Pro Max
        case 414 ..< 428:  Self.fontSize = 12.0 //Device width 414pt : iPhone 6s Plus, 7 Plus, 8 Plus, XR, 11, XS Max, 11 Pro Max
        case 390 ..< 414:  Self.fontSize = 11.3 //Device width 390pt : iPhone 12, 12 Pro
        case 375 ..< 390:  Self.fontSize = 10.5 //Device width 375pt : iPhone 6s, 7, 8, SE(2nd Gen), X, XS, 11 Pro, 12 mini
        case 320 ..< 375:  Self.fontSize =  8.8 //Device width 320pt : iPhone SE(1st Gen), iPod touch(7th Gen)
        default:           assertionFailure("ByteField.initSize: width = \(width)") //0 or Unexpeted
        }
        
        switch height {
        case 926 ..< 1500: Self.height1 = 80.0; Self.height2 = 125.0 //Device size 428x926 : iPhone 12 Pro Max
        case 896 ..< 926:  Self.height1 = 76.0; Self.height2 = 120.0 //Device size 414x896 : iPhone XR, 11, XS Max, 11 Pro Max
        case 844 ..< 896:  Self.height1 = 74.0; Self.height2 = 117.0 //Device size 390x844 : iPhone 12, 12 Pro
        case 812 ..< 844:  Self.height1 = 72.0; Self.height2 = 114.0 //Device size 375x812 : iPhone X, XS, 11 Pro  /  375x812 : iPhone 12 mini
        case 736 ..< 812:  Self.height1 = 76.0; Self.height2 = 120.0 //Device size 414x736 : iPhone 6s Plus, 7 Plus, 8 Plus
        case 667 ..< 736:  Self.height1 = 68.0; Self.height2 = 98.0 //Device size 375x667 : iPhone 6s, 7, 8, SE(2nd Gen)
        case 568 ..< 667:  Self.height1 = 50.0; Self.height2 = 80.0 //Device size 320x568 : iPhone SE(1st Gen), iPod touch(7th Gen)
        default:           assertionFailure("ByteField.initSize: height = \(height)") //0 or Unexpeted
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .trailing, spacing: 0) {
                Text(self.label)
                    .font(.system(size: Self.fontSize, weight: .semibold))
                    .foregroundColor(Color.init(.systemGray))
                    .padding(.bottom, -2)
                HStack(spacing: 5) {
                    Text(Self.bitPattern[Int(self.byte >> 4 & 0x0F)])
                        .kerning(1)
                        .font(Font.custom("Courier", size: monospaceFontSize))
                        .foregroundColor(Color.init(UIColor.label))
                    Text(Self.bitPattern[Int(self.byte & 0x0F)])
                        .kerning(1)
                        .font(Font.custom("Courier", size: monospaceFontSize))
                        .foregroundColor(Color.init(UIColor.label))
                }
            }
            Text(String(format: object.isUpper ? "%01X %01X" : "%01x %01x", (self.byte >> 4) & 0x0F, self.byte & 0x0F))
                .font(Font.custom("Menlo", size: Self.fontSize))
                .foregroundColor(Color.init(CalculatorSharedObject.isDark ? .lightGray : .darkGray))
                .padding(.top, -2)
        }
    }
}

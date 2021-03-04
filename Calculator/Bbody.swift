//
//  Bbody.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI

struct Bbody: View {
    @EnvironmentObject var object: CalcSharedObject
    var t: String? = nil         //Label of Text
    var i: String? = nil         //SystemName of Image
    let c: Int                   //Number of column in parent view
    var w: Int = 1               //Width
    var h: Int = 1               //Height
    var b: UIColor = .systemGray //Background color
    var f: UIColor = .white      //Foreground color
    var s: Bool = false          //Whether button is selected
    var v: Bool = false          //Converts Upper/Lower case depending on app setting
    var m: Bool = false          //Uses monospaced font
    
    private var buttonSpace: CGFloat { object.isStandard ? 1.0 : 5.0 }
    private var buttonWidth: CGFloat { (object.deviceWidth - self.buttonSpace * CGFloat(c - 1) - CGFloat(object.isStandard ? 0.0 : 10.0)) / CGFloat(c) }
    private var buttonHeight: CGFloat { self.buttonWidth * Self.rate }
    private var buttonRadius: CGFloat { object.isStandard ? 0.0 : self.buttonHeight / 4 }
    private var monospaceFontSize: CGFloat { Self.fontSize * 1.2 }
    
    static var rate: CGFloat = 1.0
    static var fontSize: CGFloat = 20.0
    
    static func initSize(width: CGFloat, height: CGFloat) {
        //Devices supported iOS 14 or newer
        switch height {
        case 926 ..< 1500: Self.rate = 1.0; Self.fontSize = 20.7 //Device size 428x926 : iPhone 12 Pro Max
        case 896 ..< 926:  Self.rate = 1.0; Self.fontSize = 20.0 //Device size 414x896 : iPhone XR, 11, XS Max, 11 Pro Max
        case 844 ..< 896:  Self.rate = 1.0; Self.fontSize = 18.8 //Device size 390x844 : iPhone 12, 12 Pro
        case 812 ..< 844:  Self.rate = 1.0; Self.fontSize = 18.1 //Device size 375x812 : iPhone X, XS, 11 Pro  /  375x812 : iPhone 12 mini
        case 736 ..< 812:  Self.rate = 0.8; Self.fontSize = 20.0 //Device size 414x736 : iPhone 6s Plus, 7 Plus, 8 Plus
        case 667 ..< 736:  Self.rate = 0.8; Self.fontSize = 18.0 //Device size 375x667 : iPhone 6s, 7, 8, SE(2nd Gen)
        case 568 ..< 667:  Self.rate = 0.8; Self.fontSize = 15.5 //Device size 320x568 : iPhone SE(1st Gen), iPod touch(7th Gen)
        default:           assertionFailure("SocTestScreen.initSize: width = \(height)") //0 or Unexpeted
        }
    }
    
    var body: some View {
        if useText {
            Text(self.label)
                .frame(width: buttonWidth * CGFloat(w) + buttonSpace * CGFloat(w - 1),
                       height: buttonHeight * CGFloat(h) + buttonSpace * CGFloat(h - 1),
                       alignment: .center)
                .font(m ? Font.custom("Courier", size: monospaceFontSize).monospacedDigit().bold() : .system(size: Self.fontSize, weight: .semibold))
                .foregroundColor(Color.init(f))
                .background(Color.init(b))
                .cornerRadius(object.isStandard ? 0 : buttonWidth / 4)
                .overlay(
                    RoundedRectangle(cornerRadius: object.isStandard ? 0 : buttonWidth / 4)
                        .stroke(Color.init(CalcSharedObject.isDark ? UIColor.lightGray: UIColor.darkGray), lineWidth: s ? 1 : 0)
                )
                .opacity(s ? 0.8:1.0)
        }
        else {
            Image(systemName: self.imageName)
                .frame(width: object.isStandard ? buttonWidth * CGFloat(w) + 1.0 * CGFloat(w - 1) : buttonWidth * CGFloat(w) + 5.0 * CGFloat(w - 1),
                       height: object.isStandard ? buttonHeight * CGFloat(h) + 1.0 * CGFloat(h - 1) : buttonHeight * CGFloat(h) + 5.0 * CGFloat(h - 1),
                       alignment: .center)
                .font(.system(size: Self.fontSize, weight: .semibold))
                .background(Color.init(b))
                .foregroundColor(Color.init(f))
                .cornerRadius(buttonRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: buttonRadius)
                        .stroke(Color.init(CalcSharedObject.isDark ? UIColor.lightGray: UIColor.darkGray), lineWidth: s ? 1 : 0)
                )
                .opacity(s ? 0.8 : 1.0)
        }
    }
    
    private var useText: Bool {
        if self.t != nil && self.i != nil {
            return object.isStandard
        }
        else if self.t != nil {
            return true
        }
        else {
            return false
        }
    }
    
    private var label: String {
        if let text = self.t {
            if self.v {
                return object.isUpper ? text.uppercased() : text.lowercased()
            }
            else {
                return text
            }
        }
        else {
            return ""
        }
    }
    
    private var imageName: String {
        if let name = self.i {
            return name
        }
        else {
            return ""
        }
    }
}

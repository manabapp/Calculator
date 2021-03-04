//
//  HorizontalBbody.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI

struct HorizontalBbody: View {
    @EnvironmentObject var object: CalcSharedObject
    var t: LocalizedStringKey? = nil //Label of Text
    var i: String? = nil             //SystemName of Image
    let c: Int                       //Number of column in parent view
    var w: Int = 1                   //Width
    var h: Int = 1                   //Height
    var b: UIColor = .darkGray       //Background color
    var f: UIColor = .white          //Foreground color
    
    private var buttonSpace: CGFloat { object.isStandard ? 1.0 : 5.0 }
    private var buttonWidth: CGFloat { (object.deviceWidth - self.buttonSpace * CGFloat(c - 1) - CGFloat(object.isStandard ? 0.0 : 10.0)) / CGFloat(c) }
    private var buttonHeight: CGFloat { Self.height }
    private var buttonRadius: CGFloat { object.isStandard ? 0.0 : self.buttonHeight / 4 }
    
    static var height: CGFloat = 40.0
    static var fontSize: CGFloat = 16.0
    static func initSize(width: CGFloat, height: CGFloat) {
        //Devices supported iOS 14 or newer
        switch height {
        case 926 ..< 1500: Self.height = 40.0; Self.fontSize = 16.0 //Device size 428x926 : iPhone 12 Pro Max
        case 896 ..< 926:  Self.height = 40.0; Self.fontSize = 16.0 //Device size 414x896 : iPhone XR, 11, XS Max, 11 Pro Max
        case 844 ..< 896:  Self.height = 40.0; Self.fontSize = 16.0 //Device size 390x844 : iPhone 12, 12 Pro
        case 812 ..< 844:  Self.height = 40.0; Self.fontSize = 16.0 //Device size 375x812 : iPhone X, XS, 11 Pro  /  375x812 : iPhone 12 mini
        case 736 ..< 812:  Self.height = 36.0; Self.fontSize = 14.4 //Device size 414x736 : iPhone 6s Plus, 7 Plus, 8 Plus
        case 667 ..< 736:  Self.height = 36.0; Self.fontSize = 14.4 //Device size 375x667 : iPhone 6s, 7, 8, SE(2nd Gen)
        case 568 ..< 667:  Self.height = 32.0; Self.fontSize = 12.8 //Device size 320x568 : iPhone SE(1st Gen), iPod touch(7th Gen)
        default:           assertionFailure("SocTestScreen.initSize: width = \(height)") //0 or Unexpeted
        }
    }
    
    var body: some View {
        HStack {
            if let image = self.i {
                Image(systemName: image)
            }
            if let text = self.t {
                Text(text)
            }
        }
        .frame(width: buttonWidth * CGFloat(w) + buttonSpace * CGFloat(w - 1), height: buttonHeight, alignment: .center)
        .font(.system(size: Self.fontSize))
        .background(Color.init(b))
        .foregroundColor(Color.init(f))
        .cornerRadius(buttonRadius)
    }
}

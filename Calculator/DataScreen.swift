//
//  DataScreen.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI

struct DataScreen: UIViewRepresentable {
    @EnvironmentObject var object: CalculatorSharedObject
    @Binding var text: String
    @Binding var isEditable: Bool
    @Binding var isDecodable: Bool
    
    let onEditingChanged: (Bool) -> Void
    
    init(text: Binding<String>, isEditable: Binding<Bool>, isDecodable: Binding<Bool>, onEditingChanged: @escaping (Bool) -> Void = {_ in}) {
        self._text = text
        self._isEditable = isEditable
        self._isDecodable = isDecodable
        self.onEditingChanged = onEditingChanged
    }
    
    static let fontSmall: Int = 0
    static let fontLarge: Int = 1
    
    static var fontSize: CGFloat = 9.5
    static var editorIndexWidth: CGFloat = 45.0
    static var editorHexWidth: CGFloat = 220.0
    static var editorCharsWidth: CGFloat = 110.0
    static var editorIndexWidth2: CGFloat = 82.0
    static var editorHexWidth2: CGFloat = 214.0
    static var editorCharsWidth2: CGFloat = 118.0
    
    static func initSize(width: CGFloat, height: CGFloat) {
        //Devices supported iOS 14 or newer
        switch width {
        case 428 ..< 999: //Device width 428pt : iPhone 12 Pro Max
            Self.fontSize = 10.7
            Self.editorIndexWidth = 52
            Self.editorHexWidth = 251
            Self.editorIndexWidth2 = 84.4
            Self.editorHexWidth2   = 220.1
            
        case 414 ..< 428: //Device width 414pt : iPhone 6s Plus, 7 Plus, 8 Plus, XR, 11, XS Max, 11 Pro Max
            Self.fontSize = 10.4
            Self.editorIndexWidth = 50.0
            Self.editorHexWidth = 243.0
            Self.editorIndexWidth2 = 82.0
            Self.editorHexWidth2   = 214.0
            
        case 390 ..< 414: //Device width 390pt : iPhone 12, 12 Pro
            Self.fontSize = 9.8
            Self.editorIndexWidth = 48.0
            Self.editorHexWidth = 229.0
            Self.editorIndexWidth2 = 77.3
            Self.editorHexWidth2   = 201.7
            
        case 375 ..< 390: //Device width 375pt : iPhone 6s, 7, 8, SE(2nd Gen), X, XS, 11 Pro, 12 mini
            Self.fontSize = 9.5
            Self.editorIndexWidth = 45.0
            Self.editorHexWidth = 220.0
            Self.editorIndexWidth2 = 74.9
            Self.editorHexWidth2   = 195.5
            
        case 320 ..< 375: //Device width 320pt : iPhone SE(1st Gen), iPod touch(7th Gen)
            Self.fontSize = 8.0
            Self.editorIndexWidth = 39.0
            Self.editorHexWidth = 188.0
            Self.editorIndexWidth2 = 63.1
            Self.editorHexWidth2   = 164.6
            
        default:
            assertionFailure("DataScreen.initSize: width = \(width)")
            return
        }
        Self.editorCharsWidth  = width - (Self.editorIndexWidth  + Self.editorHexWidth)
        Self.editorCharsWidth2 = width - (Self.editorIndexWidth2 + Self.editorHexWidth2)
    }
    
    private var fontRate: CGFloat { object.isCharsLarge ? 1.80 : 1.0 }
    
    func makeUIView(context: Context) -> UITextView {
        let myTextArea = UITextView()
        myTextArea.keyboardType = .asciiCapable
        myTextArea.isEditable = isEditable
        myTextArea.delegate = context.coordinator
        myTextArea.font = isDecodable ? UIFont(name: "Menlo", size: DataScreen.fontSize * fontRate) : UIFont.boldSystemFont(ofSize: (DataScreen.fontSize + 1.0) * fontRate)
        myTextArea.textAlignment = isDecodable ? .left : .center
        myTextArea.backgroundColor = UIColor.secondarySystemBackground
        myTextArea.textColor = UIColor.label
        myTextArea.text = text
        return myTextArea
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.isEditable = isEditable
        uiView.font = isDecodable ? UIFont(name: "Menlo", size: DataScreen.fontSize * fontRate) : UIFont.boldSystemFont(ofSize: (DataScreen.fontSize + 1.0) * fontRate)
        uiView.textAlignment = isDecodable ? .left : .center
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, onEditingChanged: onEditingChanged)
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        var parent: DataScreen
        let onEditingChanged: (Bool) -> Void
        
        init(_ uiTextView: DataScreen, onEditingChanged: @escaping (Bool) -> Void = {_ in}) {
            self.parent = uiTextView
            self.onEditingChanged = onEditingChanged
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
            self.parent.isEditable = textView.isEditable
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            onEditingChanged(true)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            onEditingChanged(false)
        }

    }
}

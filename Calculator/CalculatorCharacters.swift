//
//  CalculatorCharacter.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI

struct CalculatorCharacters: View {
    @EnvironmentObject var object: CalculatorSharedObject
    @State var mode: Int = 0
    @State var data = Data([])
    @State var returnCodeIndex = 1
    @State var asciiText: String = ""
    @State var hexText: String = ""
    @State var indexText: String = ""
    @State var charsText: String = ""
    @State var isAsciiEditable: Bool = true
    @State var isHexEditable: Bool = true
    @State var isAsciiDecodable: Bool = true
    @State var isHexDecodable: Bool = true  //Fixed
    @State var isOtherEditable: Bool = false  //Fixed
    @State var isOtherDecodable: Bool = true  //Fixed
    @State var isInvalid: Bool = false
    @State var isTooLarge: Bool = false
    @State var isKeyboardOpened: Bool = false
    
    private var buttonSpace: CGFloat { object.isStandard ? 1.0 : 5.0 }
    private var isClearX: Bool { self.hexText.isEmpty && self.data.count == 0 && !self.isInvalid && !self.isTooLarge }
    private var isClearA: Bool { self.asciiText.isEmpty && self.isAsciiEditable && self.isAsciiDecodable }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: self.$mode) {
                Text("UTF-8").tag(0)
            }
            .frame(height: 32)
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 1)
            
            HStack {
                Spacer()
                Text("Non-hex code included")
                    .font(.system(size: 12, weight: isInvalid ? .bold : .light))
                    .foregroundColor(isInvalid ? Color.init(.systemRed) : Color.init(CalculatorSharedObject.isDark ? .darkGray : .lightGray))
                Spacer()
                Text("Data too large")
                    .font(.system(size: 12, weight: isTooLarge ? .bold : .light))
                    .foregroundColor(isTooLarge ? Color.init(.systemRed) : Color.init(CalculatorSharedObject.isDark ? .darkGray : .lightGray))
                Spacer()
            }
            .padding(.bottom, 5)
            
            HStack(alignment: .bottom) {
                Text("Hex")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.init(UIColor.systemGray))
                    .padding(.leading, 4)
                Spacer()
                Text("\(self.data.count) " + NSLocalizedString(self.data.count == 1 ? "Label_byte" : "Label_bytes", comment: ""))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.init(UIColor.systemGray))
                    .padding(.trailing, 2)
            }
            .padding(.bottom, 2)
            
            VStack(spacing: buttonSpace) {
                HStack(spacing: 0) {
                    DataScreen(text: self.$indexText, isEditable: self.$isOtherEditable, isDecodable: self.$isOtherDecodable)
                        .frame(width: object.isCharsLarge ? DataScreen.editorIndexWidth2 : DataScreen.editorIndexWidth)
                    DataScreen(text: self.$hexText, isEditable: self.$isHexEditable, isDecodable: self.$isHexDecodable)
                        .frame(width: object.isCharsLarge ? DataScreen.editorHexWidth2 : DataScreen.editorHexWidth)
                    DataScreen(text: self.$charsText, isEditable: self.$isOtherEditable, isDecodable: self.$isOtherDecodable)
                        .frame(width: object.isCharsLarge ? DataScreen.editorCharsWidth2 : DataScreen.editorCharsWidth)
                }
                
                HStack(spacing: buttonSpace) {
                    Button(action: { self.copy(isHex: true) }) { HorizontalBbody(t: "Button_Copy", i: "doc.on.doc", c: 3, f: isInvalid ? .systemGray : .white) }.disabled(isInvalid)
                    Button(action: { self.paste(isHex: true) }) { HorizontalBbody(t: "Button_Paste", i: "doc.on.clipboard", c: 3) }
                    Button(action: { self.clear(isHex: true) }) { HorizontalBbody(t: "C", c: 3, b: .lightGray, f: .black) }
                }
                .padding(.horizontal, object.isStandard ? 0 : 5)
            }
            
            HStack(spacing: 0) {
                Spacer()
                Image(systemName: "arrowtriangle.up.circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.init(UIColor.systemGray))
                Spacer()
                Spacer()
                Image(systemName: "arrowtriangle.down.circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.init(UIColor.systemGray))
                Spacer()
            }
            .padding(.vertical, 10)
            
            HStack(alignment: .bottom) {
                Text("Ascii")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.init(UIColor.systemGray))
                    .padding(.leading, 4)
                    .padding(.bottom, -4)
                Spacer()
                Picker("", selection: self.$returnCodeIndex) {
                    Text("LF").tag(0)
                    Text("CRLF").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200, height: 32, alignment: .bottomTrailing)
                .padding(.horizontal, 1)
                .disabled(!self.isAsciiEditable)
            }
            .padding(.bottom, 8)
                
            VStack(spacing: buttonSpace) {
                DataScreen(text: self.$asciiText, isEditable: self.$isAsciiEditable, isDecodable: self.$isAsciiDecodable)
                    .padding(.top, -5)
                    .padding(.leading, 0)
                
                HStack(spacing: buttonSpace) {
                    Button(action: { self.copy(isHex: false) }) { HorizontalBbody(t: "Button_Copy", i: "doc.on.doc", c: 3, f: self.isAsciiEditable ? .white : .systemGray) }.disabled(!self.isAsciiEditable)
                    Button(action: { self.paste(isHex: false) }) { HorizontalBbody(t: "Button_Paste", i: "doc.on.clipboard", c: 3, f: self.isAsciiEditable ? .white : .systemGray) }.disabled(!self.isAsciiEditable)
                    Button(action: { self.clear(isHex: false) }) { HorizontalBbody(t: "C", c: 3, b: .lightGray, f: .black) }
                }
                .padding(.horizontal, object.isStandard ? 0 : 5)
                
                HStack(spacing: buttonSpace) {
                    Button(action: { self.convertA2X() }) { HorizontalBbody(t: "Button_Convert", i: "arrowtriangle.up.circle", c: 5, w: 2, b: .systemBlue, f: self.isAsciiEditable ? .white : .systemGray) }.disabled(!self.isAsciiEditable)
                    Button(action: { self.convertX2A() }) { HorizontalBbody(t: "Button_Convert", i: "arrowtriangle.down.circle", c: 5, w: 2, b: .systemBlue) }
                    Button(action: { UIApplication.shared.closeKeyboard() }) { HorizontalBbody(i: "keyboard.chevron.compact.down", c: 5, b: .systemBlue, f: self.isKeyboardOpened ? .white : .systemGray) }.disabled(!isKeyboardOpened)
                }
                .padding(.horizontal, object.isStandard ? 0 : 5)
                .padding(.bottom, object.isStandard ? 0 : 5)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
            self.isKeyboardOpened = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            self.isKeyboardOpened = false
        }
    }

    private func convertA2X() {
        guard !isClearA else { return }
        self.isInvalid = false
        let before = Array(self.asciiText)
        var after: String = ""
        let length = before.count
        var count: Int = 0
        
        if length == 0 {
            self.data = Data([])
        }
        else if returnCodeIndex == 1 {
            count = 1
            after += String(before[0])
            while count < length {
                if before[count] == "\n" && before[count - 1] != "\r" {
                    after += String("\r\n")
                }
                else {
                    after += String(before[count])
                }
                count += 1
            }
            self.data = after.data(using: .utf8)!
        }
        else {
            count = 0
            while count < length {
                if before[count] != "\r" || (count + 1) == length || before[count + 1] != "\n" {
                    after += String(before[count])
                }
                count += 1
            }
            self.data = after.data(using: .utf8)!
        }
        
        isTooLarge = false
        if self.data.count > 65536 {
            isTooLarge = true
            object.sound(isError: true)
            return
        }
        
        self.setIndex()
        self.setHex()
        self.setChars()
        object.sound()
    }
    
    private func convertX2A() {
        self.isInvalid = false
        guard !isClearX else { return }
        var hexString: String = ""
        var uint8array: [UInt8] = []
        var count: Int = 0
        
        var text = self.hexText.replacingOccurrences(of: " ", with: "")
        text = text.replacingOccurrences(of: "\n", with: "")
        let textArray = Array(text)
        let length = textArray.count
        
        while count < length {
            hexString = String(textArray[count])
            hexString += (count + 1) < length ? String(textArray[count + 1]) : "0"
            guard let uint8 = UInt8(hexString, radix: 16) else {
                self.isInvalid = true
                object.sound(isError: true)
                return
            }
            uint8array.append(uint8)
            count += 2
        }
        self.data = Data(uint8array)
        
        isTooLarge = false
        if self.data.count > 65536 {
            isTooLarge = true
            object.sound(isError: true)
            return
        }
        
        self.setIndex()
        self.setHex()
        self.setChars()
        
        var isCRLF: Bool = false
        if let text2 = self.getAscii(isCRLF: &isCRLF) {
            self.returnCodeIndex = isCRLF ? 1 : 0
            self.asciiText = text2
            self.isAsciiEditable = true
            self.isAsciiDecodable = true
        }
        else {
            self.asciiText = NSLocalizedString("Label_Non-unicode_character_data", comment: "")
            self.isAsciiEditable = false
            self.isAsciiDecodable = false
        }
        object.sound()
    }
    
    private func getAscii(isCRLF: inout Bool) -> String? {
        guard let asciiString = String(data: self.data, encoding: .utf8) else {
            return nil
        }
        if asciiString.contains("\r\n") {
            isCRLF = true
        }
        else {
            isCRLF = !asciiString.contains("\n")
        }
        return asciiString
    }
    
    private func setIndex() {
        var count: Int = 0
        var dumpString: String = ""
        
        while count < self.data.count {
            if count < 10000 {
                dumpString += String(format: " %04d:\n", count)
            }
            else {
                dumpString += String(format: "%05d:\n", count)
            }
            count += object.isCharsLarge ? 8 : 16
        }
        self.indexText = dumpString
    }
    
    private func setHex() {
        var count: Int = 0
        var dumpString: String = ""
        let bytes = self.data.uint8array!
        
        while count < self.data.count {
            dumpString += String(format: object.isUpper ? "%02X" : "%02x", bytes[count])
            count += 1
            if count % 16 == 0 {
                dumpString += "\n"
                continue
            }
            if count % 8 == 0 {
                if object.isCharsLarge {
                    dumpString += "\n"
                    continue
                }
            }
            if count % 4 == 0 {
                dumpString += " "
            }
        }
        self.hexText = dumpString
    }
        
    private func setChars() {
        var count: Int = 0
        var dumpString: String = ""
        let bytes = self.data.uint8array!
        
        while count < self.data.count {
            dumpString += Data.printableLetters.contains(bytes[count].char) ? String(format: "%c", bytes[count]) : "."
            count += 1
            if count % 16 == 0 {
                dumpString += "\n"
                continue
            }
            if count % 8 == 0 {
                if object.isCharsLarge {
                    dumpString += "\n"
                    continue
                }
                dumpString += " "
            }
            if count % 4 == 0 {
                if object.isCharsLarge {
                    dumpString += " "
                }
            }
        }
        self.charsText = dumpString
    }
    
    private func copy(isHex: Bool) {
        if isHex {
            guard self.data.count != 0 else { return }
            var hexString: String = ""
            let bytes = self.data.uint8array!
            for byte in bytes {
                hexString += String(format: object.isUpper ? "%02X" : "%02x", byte)
            }
            UIPasteboard.general.string = hexString
        }
        else {
            guard !self.asciiText.isEmpty else { return }
            UIPasteboard.general.string = self.asciiText
        }
        object.sound()
        object.alertMessage = NSLocalizedString("Message_Copied_to_clipboard", comment: "")
        object.isAlerting = true
        DispatchQueue.global().async {
            sleep(1)
            DispatchQueue.main.async {
                object.isAlerting = false
            }
        }
    }
    private func paste(isHex: Bool) {
        guard let text = UIPasteboard.general.string else { return }
        guard !text.isEmpty else { return }
        if isHex {
            self.hexText = text
        }
        else {
            self.asciiText = text
        }
        object.sound()
    }
    private func clear(isHex: Bool) {
        if isHex {
            guard !isClearX else { return }
            data = Data([])
            self.indexText = ""
            self.hexText = ""
            self.charsText = ""
            self.isInvalid = false
            self.isTooLarge = false
        }
        else {
            guard !isClearA else { return }
            self.asciiText = ""
            self.isAsciiEditable = true
            self.isAsciiDecodable = true
        }
        object.sound()
    }
}

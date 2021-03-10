//
//  CalculatorNumeric.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI
import Foundation
import StoreKit

let BTYPE_0: Int = 0
let BTYPE_1: Int = 1
let BTYPE_2: Int = 2
let BTYPE_3: Int = 3
let BTYPE_4: Int = 4
let BTYPE_5: Int = 5
let BTYPE_6: Int = 6
let BTYPE_7: Int = 7
let BTYPE_8: Int = 8
let BTYPE_9: Int = 9
let BTYPE_A: Int = 10
let BTYPE_B: Int = 11
let BTYPE_C: Int = 12
let BTYPE_D: Int = 13
let BTYPE_E: Int = 14
let BTYPE_F: Int = 15
let BTYPE_DOT: Int = 16
let BTYPE_SLASH: Int = 17
let BTYPE_NOT: Int = 18
let BTYPE_LEFT_SHIFT: Int = 19
let BTYPE_RIGHT_SHIFT: Int = 20
let BTYPE_PLUS_MINUS: Int = 21
let BTYPE_NOW: Int = 22
let BTYPE_2038: Int = 23
let BTYPE_2106: Int = 24
let BTYPE_DELETE: Int = 25
let BTYPE_CLEAR: Int = 26
let BTYPE_PLUS: Int = 27
let BTYPE_MINUS: Int = 28
let BTYPE_MULTIPLY: Int = 29
let BTYPE_DIVIDE: Int = 30
let BTYPE_REMAINDER: Int = 31
let BTYPE_AND: Int = 32
let BTYPE_OR: Int = 33
let BTYPE_XOR: Int = 34
let BTYPE_ENTER: Int = 35

struct CalculatorNumeric: View {
    @EnvironmentObject var object: CalculatorSharedObject
    
    @State var lastType: Int = BTYPE_0
    @State var operatorType: Int? = nil //BTYPE_PLUS(+), _MINUS(-), _MULTIPLY(*), _DIVIDE(/), _REMINDER(%), _AND(&), _OR(|), or _XOR(^)
    @State var isOutOfRange: Bool = false
    @State var isOverflow: Bool = false
    @State var isDivisionByZero: Bool = false
    @State var console: String = "0"
    @State var consoleD: Double = 0.0
    @State var consoleI: Int64 = 0
    @State var consoleX: UInt64 = 0
    @State var memoryOperandD: Double = 0.0
    @State var memoryOperandI: Int64 = 0
    @State var memoryOperandX: UInt64 = 0
    @State var memoryResultD: Double? = nil
    @State var memoryResultI: Int64? = nil
    @State var memoryResultX: UInt64? = nil
    
    private var mode: Int { object.numericMode }
    private var consoleString: String { self.console.replacingOccurrences(of:",", with:"") }
    private var buttonSpace: CGFloat { object.isStandard ? 1.0 : 5.0 }
    private var isTyping: Bool { self.lastType <= BTYPE_DELETE }
    private var hasMemoryResult: Bool {
        switch self.mode {
        case Self.modeD: return self.memoryResultD != nil
        case Self.modeI: return self.memoryResultI != nil
        default:         return self.memoryResultX != nil
        }
    }
    private var isClear: Bool     { self.console == "0" }
    private var isAllClear: Bool  { self.isClear && self.operatorType == nil && !self.hasMemoryResult && !self.isOutOfRange && !self.isOverflow && !self.isDivisionByZero }
    private var isNegative : Bool { self.console.hasPrefix("-") }
    private var isHex: Bool       { self.mode == Self.modeX }
    private var isDouble: Bool    { self.mode == Self.modeD }
    private var isPlus: Bool      { if let type = self.operatorType { return type == BTYPE_PLUS      } else { return false } }
    private var isMinus: Bool     { if let type = self.operatorType { return type == BTYPE_MINUS     } else { return false } }
    private var isMultiply: Bool  { if let type = self.operatorType { return type == BTYPE_MULTIPLY  } else { return false } }
    private var isDivide: Bool    { if let type = self.operatorType { return type == BTYPE_DIVIDE    } else { return false } }
    private var isRemainder: Bool { if let type = self.operatorType { return type == BTYPE_REMAINDER } else { return false } }
    private var isAnd: Bool       { if let type = self.operatorType { return type == BTYPE_AND       } else { return false } }
    private var isOr: Bool        { if let type = self.operatorType { return type == BTYPE_OR        } else { return false } }
    private var isXor: Bool       { if let type = self.operatorType { return type == BTYPE_XOR       } else { return false } }
    private var column: Int       { self.isHex ? 6 : 5 }
    
    //Valid range for modeD(Double)
    static let doubleMax: Double = 999999999999999
    static let doubleMin: Double = -999999999999999
    static let doublePlusMin: Double = 0.0000000001
    static let doubleMinusMax: Double = -0.0000000001
    
    static let modeD: Int = 0 //Double (64bit)
    static let modeI: Int = 1 //Signed Integer (64bit)
    static let modeX: Int = 2 //Unsigned Integer (64bit)
    
    private func d2String(_ value: Double) -> String {
        var doubleString: String = ""
        if object.appSetting1000Separator {
            doubleString = String.localizedStringWithFormat("%15.10F", value).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        else {
            doubleString = String(format: "%15.10F", value).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if doubleString.contains(".") {
            let array: [String] = doubleString.components(separatedBy: ".")
            if array.count == 2 {
                if doubleString.totalDigits > 15 {
                    doubleString = array[0]
                    let intDigits = doubleString.totalDigits - doubleString.decimalDigits
                    if intDigits < 15 {
                        doubleString += "."
                        doubleString += String(array[1].prefix(15 - intDigits))
                    }
                }
            }
        }
        return doubleString.strReplace
    }
    private func i2String(_ value: Int64) -> String {
        if object.appSetting1000Separator {
            return String.localizedStringWithFormat("%lld", value)
        }
        else {
            return String(format: "%lld", value)
        }
    }
    private func x2String(_ value: UInt64) -> String {
        return String(format: object.isUpper ? "%llX" : "%llx", value)
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: self.$object.numericMode) {
                Text("Label_Calculator_D").tag(Self.modeD)
                Text("Label_Calculator_I").tag(Self.modeI)
                Text("Label_Calculator_X").tag(Self.modeX)
            }
            .frame(height: 32)
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 1)
            .onChange(of: object.numericMode) { _ in
                switch mode {
                case Self.modeD: self.console = self.d2String(consoleD)
                case Self.modeI: self.console = self.i2String(consoleI)
                default:         self.console = self.x2String(consoleX)
                }
                self.memoryResultD = nil
                self.memoryResultI = nil
                self.memoryResultX = nil
                self.operatorType = nil
                self.memoryOperandD = 0.0
                self.memoryOperandI = 0
                self.memoryOperandX = 0
            }
            
            HStack {
                Spacer()
                Text("Out of range")
                    .font(.system(size: 12, weight: isOutOfRange ? .bold : .light))
                    .foregroundColor(isOutOfRange ? Color.init(.systemRed) : Color.init(CalculatorSharedObject.isDark ? .darkGray : .lightGray))
                Spacer()
                Text("Overflow")
                    .font(.system(size: 12, weight: isOverflow ? .bold : .light))
                    .foregroundColor(isOverflow ? Color.init(.systemRed) : Color.init(CalculatorSharedObject.isDark ? .darkGray : .lightGray))
                Spacer()
                Text("Division by zero")
                    .font(.system(size: 12, weight: isDivisionByZero ? .bold : .light))
                    .foregroundColor(isDivisionByZero ? Color.init(.systemRed) : Color.init(CalculatorSharedObject.isDark ? .darkGray : .lightGray))
                Spacer()
            }
#if DEBUG
            switch mode {
            case Self.modeD:
                Text("\(self.isTyping ? 1:0), Result: \(memoryResultD != nil ? String(memoryResultD!) : "nil"), Operand: \(memoryOperandD)")
            case Self.modeI:
                Text("\(self.isTyping ? 1:0), Result: \(memoryResultI != nil ? String(memoryResultI!) : "nil"), Operand: \(memoryOperandI)")
            default: //modeX:
                Text("\(self.isTyping ? 1:0), Result: \(memoryResultX != nil ? String(memoryResultX!) : "nil"), Operand: \(memoryOperandX)")
            }
#endif
            Spacer()
            
            Text(self.console)
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                .font(isHex ? Font.custom("Menlo", size: 64.0) : .system(size: 64))
                .padding(5)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
            
            Button(action: { object.byteFieldsClosed.toggle() }) {
                if object.byteFieldsClosed {
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: object.isStandard ? object.deviceWidth : object.deviceWidth - 10.0, height: 24, alignment: .center)
                        .foregroundColor(Color.init(.lightGray))
                        .background(Color.init(UIColor(red: 0.110, green: 0.110, blue: 0.118, alpha: 1.0)))
                        .cornerRadius(object.isStandard ? 0 : 8)
                }
                else {
                    HStack(spacing: 10) {
                        VStack(spacing: 5) {
                            ByteField(byte: self.getByte(7), label: "56")
                            ByteField(byte: self.getByte(3), label: "24")
                        }
                        VStack(spacing: 5) {
                            ByteField(byte: self.getByte(6), label: "48")
                            ByteField(byte: self.getByte(2), label: "16")
                        }
                        VStack(spacing: 5) {
                            ByteField(byte: self.getByte(5), label: "40")
                            ByteField(byte: self.getByte(1), label:  "8")
                        }
                        VStack(spacing: 5) {
                            ByteField(byte: self.getByte(4), label: "32")
                            ByteField(byte: self.getByte(0), label:  "0")
                        }
                    }
                    .frame(width: object.deviceWidth, height: ByteField.height2, alignment: .center)
                    .background(Color.init(UIColor(red: 0.110, green: 0.110, blue: 0.118, alpha: 1.0)))
                }
            }
            
            VStack(spacing: buttonSpace) {
                if isHex {
                    HStack(spacing: buttonSpace) {
                        Button(action: { tap(BTYPE_LEFT_SHIFT) }) { Bbody(t: "<<", c: column, b: .lightGray, f: .black, m: isHex) }
                        Button(action: { tap(BTYPE_D) }) { Bbody(t: "D", c: column, v: true, m: isHex) }
                        Button(action: { tap(BTYPE_E) }) { Bbody(t: "E", c: column, v: true, m: isHex) }
                        Button(action: { tap(BTYPE_F) }) { Bbody(t: "F", c: column, v: true, m: isHex) }
                        Button(action: { tap(BTYPE_CLEAR) }) { Bbody(t: isClear ? "AC":"C", c: column, w: 2, b: .lightGray, f: .black) }
                    }
                    HStack(spacing: buttonSpace) {
                        Button(action: { tap(BTYPE_RIGHT_SHIFT) }) { Bbody(t: ">>", c: column, b: .lightGray, f: .black, m: isHex) }
                        Button(action: { tap(BTYPE_A) }) { Bbody(t: "A", c: column, v: true, m: isHex) }
                        Button(action: { tap(BTYPE_B) }) { Bbody(t: "B", c: column, v: true, m: isHex) }
                        Button(action: { tap(BTYPE_C) }) { Bbody(t: "C", c: column, v: true, m: isHex) }
                        Button(action: { tap(BTYPE_PLUS_MINUS) }) { Bbody(i: isNegative ? "minus.slash.plus":"plus.slash.minus", c: column, b: .lightGray, f: .systemGray) }.disabled(true)
                        Button(action: { tap(BTYPE_DELETE) }) { Bbody(t: "DEL", i: "delete.left", c: column, b: .lightGray, f: .black) }
                    }
                }
                else {
                    HStack(spacing: buttonSpace) {
                        Button(action: { tap(BTYPE_CLEAR) }) { Bbody(t: isClear ? "AC":"C", c: column, w: 3, b: .lightGray, f: .black) }
                        Button(action: { tap(BTYPE_PLUS_MINUS) }) { Bbody(i: isNegative ? "minus.slash.plus":"plus.slash.minus", c: column, b: .lightGray, f: .black) }
                        Button(action: { tap(BTYPE_DELETE) }) { Bbody(t: "DEL", i: "delete.left", c: column, b: .lightGray, f: .black) }
                    }
                }
                HStack(spacing: buttonSpace) {
                    if isHex {
                        Button(action: { tap(BTYPE_XOR) }) { Bbody(t: object.isStandard ? "XOR":"^", c: column, b: .darkGray, s: isXor, v: true) }
                    }
                    Button(action: { tap(BTYPE_7) }) { Bbody(t: "7", c: column, v: true, m: isHex) }
                    Button(action: { tap(BTYPE_8) }) { Bbody(t: "8", c: column, v: true, m: isHex) }
                    Button(action: { tap(BTYPE_9) }) { Bbody(t: "9", c: column, v: true, m: isHex) }
                    Button(action: { tap(BTYPE_REMAINDER) }) { Bbody(t: "MOD", i: "percent", c: column, b: .darkGray, f: isDouble ? .systemGray : .white, s: isRemainder, v: true) }.disabled(isDouble)
                    Button(action: { tap(BTYPE_MINUS) }) { Bbody(i: "minus", c: column, b: .darkGray, s: isMinus) }
                }
                HStack(spacing: buttonSpace) {
                    if isHex {
                        VStack(spacing: buttonSpace) {
                            Button(action: { tap(BTYPE_OR) }) { Bbody(t: object.isStandard ? "OR":"|", c: column, b: .darkGray, s: isOr, v: true) }
                            Button(action: { tap(BTYPE_AND) }) { Bbody(t: object.isStandard ? "AND":"&", c: column, b: .darkGray, s: isAnd, v: true) }
                        }
                    }
                    VStack(spacing: buttonSpace) {
                        Button(action: { tap(BTYPE_4) }) { Bbody(t: "4", c: column, v: true, m: isHex) }
                        Button(action: { tap(BTYPE_1) }) { Bbody(t: "1", c: column, v: true, m: isHex) }
                    }
                    VStack(spacing: buttonSpace) {
                        Button(action: { tap(BTYPE_5) }) { Bbody(t: "5", c: column, v: true, m: isHex) }
                        Button(action: { tap(BTYPE_2) }) { Bbody(t: "2", c: column, v: true, m: isHex) }
                    }
                    VStack(spacing: buttonSpace) {
                        Button(action: { tap(BTYPE_6) }) { Bbody(t: "6", c: column, v: true, m: isHex) }
                        Button(action: { tap(BTYPE_3) }) { Bbody(t: "3", c: column, v: true, m: isHex) }
                    }
                    VStack(spacing: buttonSpace) {
                        Button(action: { tap(BTYPE_DIVIDE) }) { Bbody(i: object.isStandard ? "divide":"line.diagonal", c: column, b: .darkGray, s: isDivide) }
                        Button(action: { tap(BTYPE_MULTIPLY) }) { Bbody(i: object.isStandard ? "multiply":"staroflife.fill", c: column, b: .darkGray, s: isMultiply) }
                    }
                    Button(action: { tap(BTYPE_PLUS) }) { Bbody(i: "plus", c: column, h: 2, b: .darkGray, s: isPlus) }
                }
                HStack(spacing: buttonSpace) {
                    if isHex {
                        Button(action: { tap(BTYPE_NOT) }) { Bbody(t: object.isStandard ? "NOT":"~", c: column, b: .lightGray, f: .black, v: true) }
                    }
                    Button(action: { tap(BTYPE_0) }) { Bbody(t: "0", c: column, w: 2, v: true, m: isHex) }
                    Button(action: { tap(BTYPE_DOT) }) { Bbody(t: ".", c: column, f: isDouble ? .white : .lightGray, v: true) }.disabled(!isDouble)
                    Button(action: { tap(BTYPE_ENTER) }) { Bbody(i: object.isStandard ? "equal":"return", c: column, w: 2, b: .systemBlue) }
                }
                HStack(spacing: buttonSpace) {
                    Button(action: { copy() }) { HorizontalBbody(t: "Button_Copy", i: "doc.on.doc", c: 2) }
                    Button(action: { paste() }) { HorizontalBbody(t: "Button_Paste", i: "doc.on.clipboard", c: 2) }
                }
            }
            .padding(.horizontal, object.isStandard ? 0 : 5)
            .padding(.top, buttonSpace)
            .padding(.bottom, object.isStandard ? 0 : 5)
        }
    }
    

    private func getByte(_ offset: Int) -> UInt8 {
        switch mode {
        case Self.modeD:
            let data = Data(bytes: &self.consoleD, count: 8)
            let bytes = [UInt8](data)
            return bytes[offset]
        case Self.modeI:
            let value = self.consoleI >> (8 * offset)
            return UInt8(value & 0xFF)
        default: //modeX:
            let value = self.consoleX >> (8 * offset)
            return UInt8(value & 0xFF)
        }
    }
    
    private func setConsole() {
        switch self.mode {
        case Self.modeD:
            guard var value = Double(self.consoleString) else { return }
            if value.isNaN { value = 0.0 }
            consoleD = value
            consoleI = (value < Double(Int64.min) || value > Double(Int64.max)) ? 0 : Int64(value)
            consoleX = (value < 0 || value > Double(UInt64.max)) ? 0 : UInt64(value)
            
            if self.consoleString.hasPrefix("-0") { return }
            let array: [String] = self.consoleString.components(separatedBy: ".")
            if array.count < 2 {
                if let value = Int64(self.consoleString) {
                    self.console = self.i2String(value)
                }
            }
            else {
                if let value = Int64(array[0]) {
                    self.console = self.i2String(value)
                    self.console += "."
                    self.console += array[1]
                }
            }
        case Self.modeI:
            guard let value = Int64(self.consoleString) else { return }
            consoleI = value
            consoleD = (value < Int64(Self.doubleMin) || value > Int64(Self.doubleMax)) ? 0.0 : Double(value)
            consoleX = value < 0 ? 0 : UInt64(value)
            if self.console == "-0" { return }
            self.console = self.i2String(consoleI)
        default: //modeX:
            guard let value = UInt64(self.consoleString, radix: 16) else { return }
            consoleX = value
            consoleD = value > UInt64(Self.doubleMax) ? 0.0 : Double(value)
            consoleI = value > UInt64(Int64.max) ? 0 : Int64(value)
            self.console = self.x2String(consoleX)
        }
    }
    
    private func setOperand() {
        switch self.mode {
        case Self.modeD:
            guard var value = Double(self.consoleString) else { return }
            if value.isNaN { value = 0.0 }
            memoryOperandD = value
            memoryOperandI = (value < Double(Int64.min) || value > Double(Int64.max)) ? 0 : Int64(value)
            memoryOperandX = (value < 0 || value > Double(UInt64.max)) ? 0 : UInt64(value)
        case Self.modeI:
            guard let value = Int64(self.consoleString) else { return }
            memoryOperandI = value
            memoryOperandD = (value < Int64(Self.doubleMin) || value > Int64(Self.doubleMax)) ? 0.0 : Double(value)
            memoryOperandX = value < 0 ? 0 : UInt64(value)
        default: //modeX:
            guard let value = UInt64(self.consoleString, radix: 16) else { return }
            memoryOperandX = value
            memoryOperandD = value > UInt64(Self.doubleMax) ? 0.0 : Double(value)
            memoryOperandI = value > UInt64(Int64.max) ? 0 : Int64(value)
        }
    }
    
    private func setResult() {
        switch self.mode {
        case Self.modeD:
            guard var value = Double(self.consoleString) else { return }
            if value.isNaN { value = 0.0 }
            memoryResultD = value
            memoryResultI = (value < Double(Int64.min) || value > Double(Int64.max)) ? 0 : Int64(value)
            memoryResultX = (value < 0 || value > Double(UInt64.max)) ? 0 : UInt64(value)
        case Self.modeI:
            guard let value = Int64(self.consoleString) else { return }
            memoryResultI = value
            memoryResultD = (value < Int64(Self.doubleMin) || value > Int64(Self.doubleMax)) ? 0.0 : Double(value)
            memoryResultX = value < 0 ? 0 : UInt64(value)
        default: //modeX:
            guard let value = UInt64(self.consoleString, radix: 16) else { return }
            memoryResultX = value
            memoryResultD = value > UInt64(Self.doubleMax) ? 0.0 : Double(value)
            memoryResultI = value > UInt64(Int64.max) ? 0 : Int64(value)
        }
    }
    
    private func putResult() {
        switch self.mode {
        case Self.modeD: if let value = self.memoryResultD { self.console = self.d2String(value) }
        case Self.modeI: if let value = self.memoryResultI { self.console = self.i2String(value) }
        default:         if let value = self.memoryResultX { self.console = self.x2String(value) }
        }
    }
    
    private func tap(_ type: Int) {
        let willAllClear = (type == BTYPE_CLEAR && isClear)
        if self.canTyping(type) {
            let ret = self.action(type)
            object.sound(isError: !ret)
            if !ret {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
        self.setConsole()
        self.lastType = willAllClear ? BTYPE_0 : type
    }
    
    private func canTyping(_ type: Int) -> Bool {
        if self.isClear || self.console == "-0" {
            if type == BTYPE_0 {
                return false
            }
            if type <= BTYPE_F {
                return true
            }
        }
        if !self.isTyping && type < BTYPE_DELETE {
            return true
        }
        switch type {
        case BTYPE_0 ... BTYPE_9:
            switch self.mode {
            case Self.modeD:
                guard var value = Double(self.consoleString + String(type)) else { return false }
                if value.isNaN { value = 0.0 }
                guard value >= Double(Int.min) && value <= Double(Int.max) else { return false }
                guard self.consoleString.totalDigits < 15 else { return false }
                guard self.consoleString.decimalDigits < 10 else { return false }
            case Self.modeI:
                guard let _ = Int64(self.consoleString + String(type)) else { return false }
            default: //modeX:
                guard let _ = UInt64(self.consoleString + String(type), radix: 16) else { return false }
            }
            
        case BTYPE_A ... BTYPE_F:
            guard isHex else { return false }
            guard let _ = UInt64(self.consoleString + String(format: object.isUpper ? "%X" : "%x", type), radix: 16) else { return false }
            
        case BTYPE_DOT:
            guard isDouble else { return false }
            guard self.consoleString.totalDigits < 15 else { return false }
            guard !self.consoleString.contains(".") else { return false }
            
        case BTYPE_NOT:
            guard isHex else { return false }
            guard let _ = UInt64(self.consoleString, radix: 16) else { return false }
            
        case BTYPE_LEFT_SHIFT, BTYPE_RIGHT_SHIFT:
            guard isHex else { return false }
            guard let value = UInt64(self.consoleString, radix: 16) else { return false }
            guard value != 0 else { return false }
            
        case BTYPE_PLUS_MINUS:
            guard !isHex else { return false }
            
        case BTYPE_DELETE:
            guard !isClear else { return false }
            
        case BTYPE_CLEAR:
            guard !isAllClear else { return false }
            
        case BTYPE_PLUS ... BTYPE_DIVIDE:
            guard self.lastType != type else { return false }
            
        case BTYPE_REMAINDER:
            guard !isDouble else { return false }
            guard self.lastType != type else { return false }

        case BTYPE_AND ... BTYPE_XOR:
            guard isHex else { return false }
            guard self.lastType != type else { return false }

        case BTYPE_ENTER:
            guard let _ = operatorType else { return false }
            guard hasMemoryResult || isTyping else { return false }
            
        default:
            fatalError("CalculatorNumeric.canTyping: unexpected type: \(type)")
        }
        return true
    }
    
    private func action(_ type: Int) -> Bool {
        if type < BTYPE_DELETE && self.lastType == BTYPE_ENTER {
            self.memoryResultD = nil
            self.memoryResultI = nil
            self.memoryResultX = nil
        }
        switch type {
        //0123456789012345678901234567890123456789
        case BTYPE_0 ... BTYPE_9:
            if self.isTyping {
                if self.isClear {
                    self.console = String(type)
                }
                else if self.console == "-0" {
                    self.console = "-" + String(type)
                }
                else {
                    self.console = self.consoleString + String(type)
                }
            }
            else {
                self.console = String(type)
            }
            
        //ABCDEFABCDEFABCDEFABCDEFABCDEFABCDEFABCD
        case BTYPE_A ... BTYPE_F:
            if self.isTyping && !self.isClear {
                self.console = self.consoleString + String(format: object.isUpper ? "%X" : "%x", type)
            }
            else {
                self.console = String(format:  object.isUpper ? "%X" : "%x", type)
            }
            
        //........................................
        case BTYPE_DOT:
            if self.isTyping {
                self.console += "."
            }
            else {
                self.console = "0."
            }
            
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        case BTYPE_NOT:
            let value = UInt64(self.consoleString, radix: 16)!
            self.console = self.x2String(~value)

        //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        case BTYPE_LEFT_SHIFT:
            var value = UInt64(self.consoleString, radix: 16)!
            value <<= 1
            self.console = self.x2String(value)

        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        case BTYPE_RIGHT_SHIFT:
            var value = UInt64(self.consoleString, radix: 16)!
            value >>= 1
            self.console = self.x2String(value)

        //+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
        case BTYPE_PLUS_MINUS:
            if self.isTyping {
                if isNegative {
                    let substring = self.consoleString.dropFirst()
                    self.console = String(substring)
                }
                else {
                    self.console = "-" + self.consoleString
                }
            }
            else {
                self.console = "-0"
            }
            
        //DELDELDELDELDELDELDELDELDELDELDELDELDELD
        case BTYPE_DELETE:
            if self.console == "-0" {
                self.console = "0"  //Clear Console
            }
            else {
                let substring = self.consoleString.dropLast()
                self.console = String(substring)
                if self.console.isEmpty {
                    self.console = "0"  //Clear Console
                }
                else if self.console == "-" {
                    self.console = "-0"
                }
            }
            
        //CACCACCACCACCACCACCACCACCACCACCACCACCACC
        case BTYPE_CLEAR:
            if isClear {
                self.lastType = BTYPE_0
                self.isOutOfRange = false
                self.isOverflow = false
                self.isDivisionByZero = false
                self.memoryResultD = nil
                self.memoryResultI = nil
                self.memoryResultX = nil
                self.operatorType = nil
                self.memoryOperandD = 0.0
                self.memoryOperandI = 0
                self.memoryOperandX = 0
            }
            self.console = "0"  //Clear Console
            self.consoleD = 0.0
            self.consoleI = 0
            self.consoleX = 0
            
        //+-*/%&|^+-*/%&|^+-*/%&|^+-*/%&|^+-*/%&|^
        case BTYPE_PLUS ... BTYPE_XOR:
            if self.isTyping {
                self.setOperand()
                if hasMemoryResult {
                    if !self.calculate() {
                        return false
                    }
                }
                else {
                    self.memoryResultD = memoryOperandD
                    self.memoryResultI = memoryOperandI
                    self.memoryResultX = memoryOperandX
                }
                self.putResult()
            }
            self.operatorType = type
            
        //========================================
        case BTYPE_ENTER:
            if hasMemoryResult {
                if self.isTyping {
                    self.setOperand()
                }
            }
            else {
                self.setResult()
            }
            if !self.calculate() {
                return false
            }
            self.putResult()

        default:
            fatalError("CalculatorNumeric.action: unexpected type: \(type)")
        }
        return true
    }
    
    private func calculate() -> Bool {
        guard let op = self.operatorType else {
            return false
        }
        var overflow: Bool = false
        switch self.mode {
        case Self.modeD:
            let value: Double
            switch op {
            case BTYPE_PLUS:     value = self.memoryResultD! + memoryOperandD
            case BTYPE_MINUS:    value = self.memoryResultD! - memoryOperandD
            case BTYPE_MULTIPLY: value = self.memoryResultD! * memoryOperandD
            case BTYPE_DIVIDE:   value = self.memoryResultD! / memoryOperandD
            default:             fatalError("CalculatorNumeric.calculate: unexpected operator: \(op)")
            }
            if value.isInfinite || value.isNaN {
                isDivisionByZero = true
                return false
            }
            if value < Self.doubleMin || value > Self.doubleMax {
                isOutOfRange = true
                return false
            }
            if value < Self.doublePlusMin && value > Self.doubleMinusMax {
                self.memoryResultD = 0.0
            }
            else {
                self.memoryResultD = value
            }
            
        case Self.modeI:
            let value: Int64
            switch op {
            case BTYPE_PLUS:      (value, overflow) = self.memoryResultI!.addingReportingOverflow(memoryOperandI)
            case BTYPE_MINUS:     (value, overflow) = self.memoryResultI!.subtractingReportingOverflow(memoryOperandI)
            case BTYPE_MULTIPLY:  (value, overflow) = self.memoryResultI!.multipliedReportingOverflow(by: memoryOperandI)
            case BTYPE_DIVIDE:    (value, overflow) = self.memoryResultI!.dividedReportingOverflow(by: memoryOperandI)
            case BTYPE_REMAINDER: (value, overflow) = self.memoryResultI!.remainderReportingOverflow(dividingBy: memoryOperandI)
            default:              fatalError("CalculatorNumeric.calculate: unexpected operator: \(op)")
            }
            if overflow {
                if memoryOperandI == 0 {
                    isDivisionByZero = true
                }
                else {
                    isOverflow = true
                }
                return false
            }
            self.memoryResultI = value
            
        default: //modeX:
            let value: UInt64
            switch op {
            case BTYPE_PLUS:      (value, overflow) = self.memoryResultX!.addingReportingOverflow(memoryOperandX)
            case BTYPE_MINUS:     (value, overflow) = self.memoryResultX!.subtractingReportingOverflow(memoryOperandX)
            case BTYPE_MULTIPLY:  (value, overflow) = self.memoryResultX!.multipliedReportingOverflow(by: memoryOperandX)
            case BTYPE_DIVIDE:    (value, overflow) = self.memoryResultX!.dividedReportingOverflow(by: memoryOperandX)
            case BTYPE_REMAINDER: (value, overflow) = self.memoryResultX!.remainderReportingOverflow(dividingBy: memoryOperandX)
            case BTYPE_AND:       value = self.memoryResultX! & memoryOperandX
            case BTYPE_OR:        value = self.memoryResultX! | memoryOperandX
            case BTYPE_XOR:       value = self.memoryResultX! ^ memoryOperandX
            default:              fatalError("CalculatorNumeric.calculate: unexpected operator: \(op)")
            }
            if overflow {
                if memoryOperandX == 0 {
                    isDivisionByZero = true
                }
                else {
                    isOverflow = true
                }
                return false
            }
            self.memoryResultX = value
        }
        return true
    }
    
    private func copy() {
        UIPasteboard.general.string = self.consoleString
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
    
    private func paste() {
        guard var text = UIPasteboard.general.string else {
            return
        }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            return
        }
        switch self.mode {
        case Self.modeD:
            if let value = Double(text) {
                if !value.isNaN && value >= Self.doubleMin && value <= Self.doubleMax {
                    self.console = self.d2String(value)
                    self.setConsole()
                    self.lastType = BTYPE_0
                    object.sound()
                }
            }
        case Self.modeI:
            if let value = Int64(text) {
                self.console = self.i2String(value)
                self.setConsole()
                self.lastType = BTYPE_0
                object.sound()
            }
        default: //modeX:
            if let value = UInt64(text, radix: 16) {
                self.console = self.x2String(value)
                self.setConsole()
                self.lastType = BTYPE_0
                object.sound()
            }
        }
    }
}

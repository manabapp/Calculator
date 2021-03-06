//
//  CalculatorUNIXTime.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI

struct CalculatorUNIXTime: View {
    @EnvironmentObject var object: CalculatorSharedObject
    @State var date: Date = Date(timeIntervalSince1970: 0)
    @State var time: UInt32 = 0
    @State var console: String = "0"
    @State var year: Int = 0
    @State var month: Int = 0
    @State var day: Int = 0
    @State var hour: Int = 0
    @State var minute: Int = 0
    @State var second: Int = 0
    @State var isShowing = false
    
    static let modeLocal: Int = 0
    static let modeUTC: Int = 1
    static let dateMin = Date(timeIntervalSince1970: 0)
    static let dateMax = Date(timeIntervalSince1970: TimeInterval(UInt32.max))
    
    static var calendarUTC = Calendar(identifier: .gregorian)
    static var calendarLocal = Calendar(identifier: .gregorian)
    static var formatterUTC = DateFormatter()
    static var formatterLocal = DateFormatter()
    static func initTime() {
        calendarUTC.timeZone = TimeZone(abbreviation: "UTC")!
        formatterUTC.timeZone = TimeZone(abbreviation: "UTC")
        formatterUTC.calendar = calendarUTC
        formatterUTC.dateStyle = .long
        formatterUTC.timeStyle = .medium
        
        calendarLocal.timeZone = TimeZone.current
        formatterLocal.timeZone = TimeZone.current
        formatterLocal.calendar = calendarUTC
        formatterLocal.dateStyle = .long
        formatterLocal.timeStyle = .medium
    }
    
    private var mode: Int { object.unixTimeMode }
    private var consoleString: String { self.console.replacingOccurrences(of:",", with:"") }
    private var time2String: String { object.appSetting1000Separator ? String.localizedStringWithFormat("%lld", self.time) : String(format: "%lld", self.time) }
    private var isClear: Bool { self.console == "0" }
    private var isAllClear: Bool  { self.isClear && self.time == 0 }
    private var isLocal: Bool { self.mode == Self.modeLocal }
    private var calendar: Calendar { self.isLocal ? Self.calendarLocal : Self.calendarUTC }
    private var formatter: DateFormatter { self.isLocal ? Self.formatterLocal : Self.formatterUTC }
    
    private var buttonSpace: CGFloat { object.isStandard ? 3.0 : 1.0 }
    private var buttonMargin: CGFloat { object.isStandard ? 3.0 : 0.0 }
    private var fieldsRadius: CGFloat { object.isStandard ? 8.0 : 0.0 }
    private var buttonWidth: CGFloat { (object.deviceWidth - self.buttonSpace * 4 - self.buttonMargin * 2) / 5 }
    private var buttonHeight: CGFloat { self.buttonWidth * Bbody.rate }
    private var inputsHeight: CGFloat { self.buttonHeight * 4 + HorizontalBbody.height + self.buttonSpace * 4 + self.buttonMargin * 1 }
    private var pickerWidthYear: CGFloat { 60.0 }
    private var pickerWidth: CGFloat { (object.deviceWidth - self.pickerWidthYear - 8.0 * 5 - 5.0 * 11) / 5 }
    private var pickersHeight: CGFloat { self.inputsHeight - HorizontalBbody.height * 2 - self.buttonMargin * 1 }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    Picker("", selection: self.$object.unixTimeMode) {
                        Text("Label_Local_Time").tag(Self.modeLocal)
                        Text("Label_UTC").tag(Self.modeUTC)
                    }
                    .frame(height: 32)
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 1)
                    .onChange(of: object.unixTimeMode) { _ in
                        setDate()
                    }
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(NSLocalizedString("Label_TimeZone", comment: "") + formatter.timeZone.identifier)
                            .foregroundColor(Color.init(CalculatorSharedObject.isDark ? .lightGray : .darkGray))
                        
                        Text(formatter.string(from: self.date))
                            .font(.system(size: 24))
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            .padding(.bottom, 10)

                        Text(self.console)
                            .font(.system(size: 64))
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                    }
                    .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                    .padding(5)
                    
                    Button(action: { object.byteFieldsClosed.toggle(); object.sound(SOUND_TYPE_OPEN_CLOSE) }) {
                        if object.byteFieldsClosed {
                            Image(systemName: "chevron.compact.up")
                                .font(.system(size: 20, weight: .semibold))
                                .frame(width: object.deviceWidth, height: 24, alignment: .center)
                                .foregroundColor(Color.init(CalculatorSharedObject.isDark ? .lightGray : .darkGray))
                                .background(Color.init(UIColor.secondarySystemBackground))
                        }
                        else {
                            HStack(spacing: 10) {
                                ByteField(byte: UInt8(self.time >> 24 & 0xFF), label: "24")
                                ByteField(byte: UInt8(self.time >> 16 & 0xFF), label: "16")
                                ByteField(byte: UInt8(self.time >>  8 & 0xFF), label:  "8")
                                ByteField(byte: UInt8(self.time >>  0 & 0xFF), label:  "0")
                            }
                            .frame(width: object.deviceWidth, height: ByteField.height1, alignment: .center)
                            .background(Color.init(UIColor.secondarySystemBackground))
                        }
                    }
                    
                    VStack(spacing: buttonSpace) {
                        HStack(spacing: buttonSpace) {
                            Button(action: { tap(BTYPE_7) }) { Bbody(t: "7", c: 5) }
                            Button(action: { tap(BTYPE_8) }) { Bbody(t: "8", c: 5) }
                            Button(action: { tap(BTYPE_9) }) { Bbody(t: "9", c: 5) }
                            Button(action: { tap(BTYPE_CLEAR) }) { Bbody(t: "C", c: 5, w: 2, b: .lightGray, f: .black) }
                        }
                        HStack(spacing: buttonSpace) {
                            Button(action: { tap(BTYPE_4) }) { Bbody(t: "4", c: 5) }
                            Button(action: { tap(BTYPE_5) }) { Bbody(t: "5", c: 5) }
                            Button(action: { tap(BTYPE_6) }) { Bbody(t: "6", c: 5) }
                            Button(action: { tap(BTYPE_DELETE) }) { Bbody(t: "DEL", i: "delete.left", c: 5, w: 2, b: .lightGray, f: .black) }
                        }
                        HStack(spacing: buttonSpace) {
                            Button(action: { tap(BTYPE_1) }) { Bbody(t: "1", c: 5) }
                            Button(action: { tap(BTYPE_2) }) { Bbody(t: "2", c: 5) }
                            Button(action: { tap(BTYPE_3) }) { Bbody(t: "3", c: 5) }
                            Button(action: { tap(BTYPE_2038) }) { Bbody(t: "2038", c: 5, b: .lightGray, f: .black) }
                            Button(action: { tap(BTYPE_2106) }) { Bbody(t: "2106", c: 5, b: .lightGray, f: .black) }
                        }
                        HStack(spacing: buttonSpace) {
                            Button(action: { tap(BTYPE_0) }) { Bbody(t: "0", c: 5, w: 3) }
                            Button(action: { tap(BTYPE_NOW) }) { Bbody(t: "now", c: 5, w: 2, b: .lightGray, f: .black) }
                        }
                        HStack(spacing: buttonSpace) {
                            Button(action: { copy() }) { HorizontalBbody(t: "Button_Copy", i: "doc.on.doc", c: 3) }
                            Button(action: { paste() }) { HorizontalBbody(t: "Button_Paste", i: "doc.on.clipboard", c: 3) }
                            Button(action: { setDate(); self.isShowing.toggle(); object.sound(SOUND_TYPE_OPEN_CLOSE) }) { HorizontalBbody(i: "chevron.up", c: 3, b: .systemBlue) }
                        }
                    }
                    .padding(.horizontal, buttonMargin)
                    .padding(.top, buttonSpace)
                    .padding(.bottom, buttonMargin)
                    .background(Color.init(UIColor.secondarySystemBackground))
                }
                
                VStack(spacing: 0) {
                    HStack(spacing: buttonSpace) {
                        Button(action: { tap(BTYPE_CLEAR) }) { HorizontalBbody(t: "C", c: 4, b: .lightGray, f: .black) }
                        Button(action: { tap(BTYPE_NOW) }) { HorizontalBbody(t: "now", c: 4, b: .lightGray, f: .black) }
                        Button(action: { tap(BTYPE_2038) }) { HorizontalBbody(t: "2038", c: 4, b: .lightGray, f: .black) }
                        Button(action: { tap(BTYPE_2106) }) { HorizontalBbody(t: "2106", c: 4, b: .lightGray, f: .black) }
                    }
                    .padding(.horizontal, buttonMargin)
                    
                    HStack(spacing: 5.0) {
                        Picker(selection: $year, label: Text("")) {
                            ForEach(1970 ..< 2107) { num in
                                Text(String(format: "%04d", num)).font(.system(size: 18))
                            }
                        }
                        .frame(width: pickerWidthYear)
                        .clipped()
                        .onChange(of: year) { _ in self.setUnixTime() }
                        Text("/").font(.system(size: 24, weight: .semibold)).frame(width: 8).foregroundColor(Color.init(.systemGray))

                        Picker(selection: $month, label: Text("")) {
                            ForEach(0 ..< 12) { num in
                                Text(String(format: "%02d", (num + 1))).font(.system(size: 18))
                            }
                        }
                        .frame(width: pickerWidth)
                        .clipped()
                        .onChange(of: month) { _ in self.setUnixTime() }
                        Text("/").font(.system(size: 24, weight: .semibold)).frame(width: 8).foregroundColor(Color.init(.systemGray))
                        
                        Picker(selection: $day, label: Text("")) {
                            ForEach(0 ..< 31) { num in
                                Text(String(format: "%02d", (num + 1))).font(.system(size: 18))
                            }
                        }
                        .frame(width: pickerWidth)
                        .clipped()
                        .onChange(of: day) { _ in self.setUnixTime() }
                        .padding(.trailing, 8)
                        
                        Picker(selection: $hour, label: Text("")) {
                            ForEach(0 ..< 24) { num in
                                Text(String(format: "%02d", num)).font(.system(size: 18))
                            }
                        }
                        .frame(width: pickerWidth)
                        .clipped()
                        .onChange(of: hour) { _ in self.setUnixTime() }
                        Text(":").font(.system(size: 24, weight: .semibold)).frame(width: 5).foregroundColor(Color.init(.systemGray))
                        
                        Picker(selection: $minute, label: Text("")) {
                            ForEach(0 ..< 60) { num in
                                Text(String(format: "%02d", num)).font(.system(size: 18))
                            }
                        }
                        .frame(width: pickerWidth)
                        .clipped()
                        .onChange(of: minute) { _ in self.setUnixTime() }
                        Text(":").font(.system(size: 24, weight: .semibold)).frame(width: 5).foregroundColor(Color.init(.systemGray))

                        Picker(selection: $second, label: Text("")) {
                            ForEach(0 ..< 60) { num in
                                Text(String(format: "%02d", num)).font(.system(size: 18))
                            }
                        }
                        .frame(width: pickerWidth)
                        .clipped()
                        .onChange(of: second) { _ in self.setUnixTime() }
                    }
                    .frame(height: pickersHeight)
                    .padding(.horizontal, 5)
                    
                    HStack(spacing: buttonSpace) {
                        Button(action: { copy() }) { HorizontalBbody(t: "Button_Copy", i: "doc.on.doc", c: 3) }
                        Button(action: { paste() }) { HorizontalBbody(t: "Button_Paste", i: "doc.on.clipboard", c: 3) }
                        Button(action: { self.isShowing.toggle(); object.sound(SOUND_TYPE_OPEN_CLOSE) }) { HorizontalBbody(i: "chevron.down", c: 3, b: .systemBlue) }
                    }
                    .padding(.horizontal, buttonMargin)
                    .padding(.bottom, buttonMargin)

                    Spacer()
                }
                .background(Color.init(UIColor.secondarySystemBackground))
                .frame(maxWidth: .infinity)
                .animation(.linear)
                .offset(y: self.isShowing ? geometry.size.height - inputsHeight : object.deviceHeight)
            }
        }
    }
    
    private func tap(_ type: Int) {
        if self.action(type) {
            object.sound()
            self.console = self.time2String
        }
    }
    private func action(_ type: Int) -> Bool {
        switch type {
        //0123456789012345678901234567890123456789
        case BTYPE_0:
            guard !isClear else { return false }
            guard let t = UInt32(self.consoleString + String(type)) else { return false }
            self.time = t
            self.date = Date(timeIntervalSince1970: Double(self.time))
            
        case BTYPE_1 ... BTYPE_9:
            if isClear {
                self.time = UInt32(type)
            }
            else {
                guard let t = UInt32(self.consoleString + String(type)) else { return false }
                self.time = t
            }
            self.date = Date(timeIntervalSince1970: Double(self.time))

        //NowNowNowNowNowNowNowNowNowNowNowNowNowN
        case BTYPE_NOW:
            self.date = Date()
            let now = UInt32(self.date.timeIntervalSince1970)
            guard now != self.time else { return false }
            self.time = now
            self.setDate()
            
        //2038203820382038203820382038203820382038
        case BTYPE_2038:
            guard self.time != UInt32(Int32.max) else { return false }
            self.time = UInt32(Int32.max)
            self.date = Date(timeIntervalSince1970: Double(self.time))
            self.setDate()
            
        //2106210621062106210621062106210621062106
        case BTYPE_2106:
            guard self.time != UInt32.max else { return false }
            self.time = UInt32.max
            self.date = Date(timeIntervalSince1970: Double(self.time))
            self.setDate()
            
        //DELDELDELDELDELDELDELDELDELDELDELDELDELD
        case BTYPE_DELETE:
            guard !isClear else { return false }
            let substring = self.consoleString.dropLast()
            self.console = substring.isEmpty ? "0" : String(substring)
            guard let t = UInt32(self.consoleString) else { return false }
            self.time = t
            self.date = Date(timeIntervalSince1970: Double(self.time))
            
        //CACCACCACCACCACCACCACCACCACCACCACCACCACC
        case BTYPE_CLEAR:
            guard !isAllClear else { return false }
            self.time = 0
            self.date = Date(timeIntervalSince1970: 0)
            self.setDate()
            
        default:
            fatalError("CalculatorUNIXTime.action: unexpected type: \(type)")
        }
        return true
    }
    
    private func copy() {
        UIPasteboard.general.string = self.consoleString
        object.alert(NSLocalizedString("Message_Copied_to_clipboard", comment: ""))
        object.sound(SOUND_TYPE_COPY)
    }
    
    private func paste() {
        guard var text = UIPasteboard.general.string else {
            return
        }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            return
        }
        if let value = UInt32(text) {
            self.console = String(format: "%lld", value)
            self.time = value
            self.date = Date(timeIntervalSince1970: Double(self.time))
            self.setDate()
            object.sound()
        }
    }
    
    private func setDate() {
        self.year = self.calendar.component(.year, from: date) - 1970
        self.month = self.calendar.component(.month, from: date) - 1
        self.day = self.calendar.component(.day, from: date) - 1
        self.hour = self.calendar.component(.hour, from: date)
        self.minute = self.calendar.component(.minute, from: date)
        self.second = self.calendar.component(.second, from: date)
    }
    
    private func setUnixTime() {
        guard let calDate = calendar.date(from: DateComponents(year: self.year + 1970, month: self.month + 1, day: self.day + 1,
                                                               hour: self.hour, minute: self.minute, second: self.second)) else {
            return
        }
        if calDate < Self.dateMin || calDate > Self.dateMax {
            object.alert(NSLocalizedString("Message_Overflow", comment: ""))
            object.sound(SOUND_TYPE_ERROR)
            return
        }
        self.date = calDate
        self.time = UInt32(self.date.timeIntervalSince1970)
        self.console = self.time2String
        self.setDate()
    }
}

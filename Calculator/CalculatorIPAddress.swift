//
//  CalculatorIPAddress.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI

struct CalculatorIPAddress: View {
    @EnvironmentObject var object: CalculatorSharedObject
    @State var mode: Int = Self.modeIPv4
    @State var console: String = ""
    @State var isInvalid: Bool = false
    @State var ipaddr: UInt32 = 0
    @State var netmask: UInt32 = 0
    @State var prefixlen: Int = 0
    @State var netaddr: UInt32? = nil
    @State var subnetmask: UInt32? = nil //same as netmask
    @State var broadcast: UInt32? = nil
    
    static let modeIPv4: Int = 0
    static let modeIPv6: Int = 1
    
    private var buttonSpace: CGFloat { object.isStandard ? 1.0 : 5.0 }
    private var isClear: Bool { self.console.isEmpty }
    private var isAllClear: Bool  { self.isClear && !self.isInvalid && self.netaddr == nil && self.subnetmask == nil && self.broadcast == nil }
    private var hasSlash: Bool { self.console.contains("/") }
    private var consoleField: Text { self.isClear ? Text("           192.168.10.0/24").foregroundColor(Color.init(CalculatorSharedObject.isDark ? .darkGray : .lightGray)) : Text(self.console) }
    
    private var prefixLen: Int {
        guard var netmask = self.subnetmask else {
            return 0
        }
        var len: Int = 0
        while netmask > 0 {
            netmask <<= 1
            len += 1
        }
        return len
    }
    private func addressField(label: LocalizedStringKey, addr: UInt32?, prefix: String = "") -> some View {
        return HStack {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.init(UIColor.systemGray))
            Spacer()
            if let address = addr {
                Text(String.init(cString: inet_ntoa(in_addr(s_addr: address.bigEndian))) + prefix)
                    .font(.system(size: 16))
            }
            else {
                Text("0.0.0.0" + prefix)
                    .font(.system(size: 16))
                    .foregroundColor(Color.init(UIColor.systemGray))
            }
        }
        .padding(.horizontal, 10)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: self.$mode) {
                Text("IPv4").tag(Self.modeIPv4)
                Text("IPv6").tag(Self.modeIPv6)
            }
            .frame(height: 32)
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 1)
            .onChange(of: mode) { mode in
                if mode == Self.modeIPv6 {
                    self.object.alertMessage = NSLocalizedString("Message_IPv6NotSupport", comment: "")
                    self.object.alertDetail = ""
                    self.object.isPopAlert = true
                    self.mode = Self.modeIPv4
                }
            }
            
            HStack {
                Spacer()
                Text("Address invalid")
                    .font(.system(size: 12, weight: isInvalid ? .bold : .light))
                    .foregroundColor(isInvalid ? Color.init(.systemRed) : Color.init(CalculatorSharedObject.isDark ? .darkGray : .lightGray))
                Spacer()
            }
            .padding(.bottom, 5)
            
            addressField(label: "Label_CIDR", addr: self.netaddr, prefix: "/\(prefixLen)")
            addressField(label: "Label_Subnet_Mask", addr: self.subnetmask)
            addressField(label: "Label_Network_Address", addr: prefixLen >= 31 ? nil : self.netaddr)
            addressField(label: "Label_Broadcast_Address", addr: prefixLen >= 31 ? nil : self.broadcast)
            
            Spacer()
            self.consoleField
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .font(.system(size: 54.0))
                .padding(5)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
            
            Button(action: { object.byteFieldsClosed.toggle() }) {
                if object.byteFieldsClosed {
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: object.isStandard ? object.deviceWidth : object.deviceWidth - 10.0, height: 24, alignment: .center)
                        .foregroundColor(Color.init(CalculatorSharedObject.isDark ? .lightGray : .darkGray))
                        .background(Color.init(UIColor.secondarySystemBackground))
                        .cornerRadius(object.isStandard ? 0 : 8)
                }
                else {
                    VStack(spacing: 5) {
                        HStack(spacing: 10) {
                            ByteField(byte: UInt8(ipaddr >> 24 & 0xFF), label: "24")
                            ByteField(byte: UInt8(ipaddr >> 16 & 0xFF), label: "16")
                            ByteField(byte: UInt8(ipaddr >>  8 & 0xFF), label: "8")
                            ByteField(byte: UInt8(ipaddr >>  0 & 0xFF), label: "0")
                        }
                        HStack(spacing: 10) {
                            ByteField(byte: UInt8(netmask >> 24 & 0xFF), label: "")
                            ByteField(byte: UInt8(netmask >> 16 & 0xFF), label: "")
                            ByteField(byte: UInt8(netmask >>  8 & 0xFF), label: "")
                            ByteField(byte: UInt8(netmask >>  0 & 0xFF), label: "netmask")
                        }
                    }
                    .frame(width: object.deviceWidth, height: ByteField.height2, alignment: .center)
                    .background(Color.init(UIColor.secondarySystemBackground))
                }
            }
            
            VStack(spacing: buttonSpace) {
                HStack(spacing: buttonSpace) {
                    Button(action: { tap(BTYPE_7) }) { Bbody(t: "7", c: 5) }
                    Button(action: { tap(BTYPE_8) }) { Bbody(t: "8", c: 5) }
                    Button(action: { tap(BTYPE_9) }) { Bbody(t: "9", c: 5) }
                    Button(action: { tap(BTYPE_CLEAR) }) { Bbody(t: "AC", c: 5, w: 2, b: .lightGray, f: .black) }
                }
                HStack(spacing: buttonSpace) {
                    VStack(spacing: buttonSpace) {
                        Button(action: { tap(BTYPE_4) }) { Bbody(t: "4", c: 5) }
                        Button(action: { tap(BTYPE_1) }) { Bbody(t: "1", c: 5) }
                    }
                    VStack(spacing: buttonSpace) {
                        Button(action: { tap(BTYPE_5) }) { Bbody(t: "5", c: 5) }
                        Button(action: { tap(BTYPE_2) }) { Bbody(t: "2", c: 5) }
                    }
                    VStack(spacing: buttonSpace) {
                        Button(action: { tap(BTYPE_6) }) { Bbody(t: "6", c: 5) }
                        Button(action: { tap(BTYPE_3) }) { Bbody(t: "3", c: 5) }
                    }
                    Button(action: { tap(BTYPE_SLASH) }) { Bbody(t: "/", c: 5, h: 2, f: .white) }
                    Button(action: { tap(BTYPE_DELETE) }) { Bbody(t: "DEL", i: "delete.left", c: 5, h: 2, b: .lightGray, f: .black) }
                }
                HStack(spacing: buttonSpace) {
                    Button(action: { tap(BTYPE_0) }) { Bbody(t: "0", c: 5, w: 2) }
                    Button(action: { tap(BTYPE_DOT) }) { Bbody(t: ".", c: 5) }
                    Button(action: { tap(BTYPE_ENTER) }) { Bbody(i: object.isStandard ? "equal":"return", c: 5, w: 2, b: .systemBlue, f: .white) }
                }
                HStack(spacing: buttonSpace) {
                    Button(action: { self.copy() }) { HorizontalBbody(t: "Button_Copy", i: "doc.on.doc", c: 2) }
                    Button(action: { self.paste() }) { HorizontalBbody(t: "Button_Paste", i: "doc.on.clipboard", c: 2) }
                }
            }
            .padding(.horizontal, object.isStandard ? 0 : 5)
            .padding(.top, buttonSpace)
            .padding(.bottom, object.isStandard ? 0 : 5)
        }
    }
    
    private func syncConsole() {
        ipaddr = 0
        netmask = 0
        if isClear {
            return
        }
        var ipAddr: String = self.console
        var prefixlen = 0
        if hasSlash {
            let array: [String] = self.console.components(separatedBy: "/")
            ipAddr = array[0]
            if let num = Int(array[1]) {
                prefixlen = num
            }
        }
        let array: [String] = ipAddr.components(separatedBy: ".")
        if array.count >= 1 {
            if let octet = UInt8(array[0]) {
                ipaddr += UInt32(octet) * 256 * 256 * 256
            }
        }
        if array.count >= 2 {
            if let octet = UInt8(array[1]) {
                ipaddr += UInt32(octet) * 256 * 256
            }
        }
        if array.count >= 3 {
            if let octet = UInt8(array[2]) {
                ipaddr += UInt32(octet) * 256
            }
        }
        if array.count >= 4 {
            if let octet = UInt8(array[3]) {
                ipaddr += UInt32(octet)
            }
        }
        if prefixlen > 0 && prefixlen <= 32 {
            netmask = UInt32(0xffffffff) << (32 - prefixlen)
        }
    }
    
    private func tap(_ type: Int) {
        if self.action(type) {
            object.sound()
            syncConsole()
        }
    }
    private func action(_ type: Int) -> Bool {
        switch type {
        //0123456789012345678901234567890123456789
        case BTYPE_0 ... BTYPE_9:
            guard self.console != "0" else { return false }
            guard !self.console.hasSuffix(".0") else { return false }
            guard !self.console.hasSuffix("/0") else { return false }
            if hasSlash {
                let array: [String] = self.console.components(separatedBy: "/")
                guard let prefixLen = UInt8(array[1] + String(type)) else { return false }
                guard prefixLen >= 0 && prefixLen <= 32 else { return false }
            }
            else {
                let array: [String] = self.console.components(separatedBy: ".")
                guard array.count > 0 else { return false }
                guard let _ = UInt8(array[array.count - 1] + String(type)) else { return false }
            }
            if self.isClear {
                self.console = String(type)
            }
            else {
                self.console += String(type)
            }
            
        //........................................
        case BTYPE_DOT:
            guard !self.isClear else { return false }
            guard !self.console.hasSuffix(".") else { return false }
            guard self.console.components(separatedBy: ".").count < 4 else { return false }
            guard !hasSlash else { return false }
            self.console += "."
            
        //-///////////////////////////////////////
        case BTYPE_SLASH:
            guard !self.isClear else { return false }
            guard !self.console.hasSuffix(".") else { return false }
            guard self.console.components(separatedBy: ".").count == 4 else { return false }
            guard !hasSlash else { return false }
            self.console += "/"
            
        //DELDELDELDELDELDELDELDELDELDELDELDELDELD
        case BTYPE_DELETE:
            guard !isClear else { return false }
            let substring = self.console.dropLast()
            self.console = String(substring)
            
        //CACCACCACCACCACCACCACCACCACCACCACCACCACC
        case BTYPE_CLEAR:
            guard !isAllClear else { return false }
            isInvalid = false
            netaddr = nil
            subnetmask = nil
            broadcast = nil
            self.console = ""
            
        //========================================
        case BTYPE_ENTER:
            isInvalid = false
            netaddr = nil
            subnetmask = nil
            broadcast = nil
            guard !isClear else { return false }
            if !hasSlash {
                guard self.console.isValidIPv4Format else {
                    object.sound(isError: true)
                    isInvalid = true
                    return false
                }
                return true
            }
            guard self.console.isValidCidrFormat else {
                object.sound(isError: true)
                isInvalid = true
                return false
            }
            netaddr = ipaddr & netmask
            subnetmask = netmask
            broadcast = netaddr! | ~netmask
            
        default:
            fatalError("CalculatorIPAddress.action: unexpected type: \(type)")
        }
        return true
    }
    
    private func copy() {
        guard !isClear else {
            return
        }
        UIPasteboard.general.string = self.console
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
        guard text.isValidIPv4Format || text.isValidCidrFormat else {
            return
        }
        self.console = text
        object.sound()
    }
}

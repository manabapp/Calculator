//
//  CalculatorMenu.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI

let MAIL_ADDRESS = "manabapp@gmail.com"
let COPYRIGHT = "Copyright © 2021 manabapp. All rights reserved."
let URL_BASE = "https://manabapp.github.io/"
let URL_WEBPAGE = URL_BASE + "Apps/index.html"
let URL_WEBPAGE_JA = URL_BASE + "Apps/index_ja.html"
let URL_POLICY = URL_BASE + "Calculator/PrivacyPolicy.html"
let URL_POLICY_JA = URL_BASE + "Calculator/PrivacyPolicy_ja.html"

struct CalculatorMenu: View {
    @EnvironmentObject var object: CalculatorSharedObject
    
    var body: some View {
        List {
            Section(header: Text("Header_PREFERENCES")) {
                NavigationLink(destination: AppSetting()) {
                    CommonRaw(name:"App Settings", image:"wrench", detail:"Description_App_Settings")
                }
            }
            Section(header: Text("Header_INFORMATION")) {
                NavigationLink(destination: AboutApp()) {
                    CommonRaw(name:"About App", image:"info.circle", detail:"Description_About_App")
                }
                NavigationLink(destination: NumericSpecification()) {
                    CommonRaw(name:"Numeric Specification", image:"questionmark.circle", detail:"Description_Numeric_Specification")
                }
                Button(action: {
                    self.openURL(urlString: CalculatorSharedObject.isJa ? URL_POLICY_JA : URL_POLICY)
                }) {
                    CommonRaw(name:"Privacy Policy", image:"hand.raised.fill", detail:"Description_Privacy_Policy")
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("Label_Menu", displayMode: .inline)
    }
    
    func openURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            self.object.alertMessage = NSLocalizedString("Message_CantOpenURL", comment: "")
            self.object.alertDetail = ""
            self.object.isPopAlert = true
            return
        }
        guard UIApplication.shared.canOpenURL(url) else {
            self.object.alertMessage = NSLocalizedString("Message_CantOpenURL", comment: "")
            self.object.alertDetail = ""
            self.object.isPopAlert = true
            return
        }
        UIApplication.shared.open(url)
    }
}

fileprivate struct CommonRaw: View {
    let name: String
    let image: String
    let detail: LocalizedStringKey
    
    var body: some View {
        HStack {
            Image(systemName: self.image)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(self.name)
                    .font(.system(size: 20))
                Text(self.detail)
                    .font(.system(size: 12))
                    .foregroundColor(Color.init(UIColor.systemGray))
            }
            .padding(.leading)
        }
    }
}

fileprivate struct AppSetting: View {
    @EnvironmentObject var object: CalculatorSharedObject
    
    var body: some View {
        List {
            Section(header: Text("VIEW").font(.system(size: 16, weight: .semibold)),
                    footer: Text("Footer_VIEW").font(.system(size: 12))) {
                HStack {
                    Text("Label_Theme")
                    Spacer()
                    Picker("", selection: self.$object.appSettingTheme) {
                        Text("Label_Standard").tag(CalculatorSharedObject.themeStandard)
                        Text("Label_Programmer").tag(CalculatorSharedObject.themeProgrammer)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 230)
                }
                Toggle(isOn: self.$object.appSetting1000Separator) {
                    Text("Label_THOUSANDS_SEPARATOR")
                }
                Toggle(isOn: self.$object.appSettingUppercaseLetter) {
                    Text("Label_UPPERCASE_LETTER")
                }
            }
            Section(header: Text("IDLE TIMER").font(.system(size: 16, weight: .semibold)),
                    footer: Text("Footer_IDLE_TIMER").font(.system(size: 12))) {
                Toggle(isOn: self.$object.appSettingIdleTimerDisabled) {
                    Text("Label_Disabled")
                }
            }
            Section(header: Text("SOUND EFFECTS").font(.system(size: 16, weight: .semibold)),
                    footer: Text("Footer_SOUND_EFFECTS").font(.system(size: 12))) {
                Toggle(isOn: self.$object.appSettingSoundEffects) {
                    Text("Label_Enabled")
                }
                if object.appSettingSoundEffects {
                    Toggle(isOn: self.$object.appSettingVibration) {
                        Text("Label_Vibration")
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("App Settings", displayMode: .inline)
    }
}

fileprivate struct AboutApp: View {
    @EnvironmentObject var object: CalculatorSharedObject
    
    var body: some View {
        VStack {
            Group {
                Image("SplashImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, alignment: .center)
                Text("Calculation")
                    .font(.system(size: 26, weight: .bold))
                Text("version " + object.appVersion)
                    .font(.system(size: 16))
                    .padding(.bottom, 5)
                Text("This app is programmer's calculator/converter.")
                    .font(.system(size: 11))
            }
            Button(action: {
                self.openURL(urlString: CalculatorSharedObject.isJa ? URL_WEBPAGE_JA : URL_WEBPAGE)
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "safari")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                    Text("Developer Website")
                        .font(.system(size: 11))
                    Spacer()
                }
                .padding(.bottom, 5)
            }
            
            Text("Support OS: iOS 14.1 or newer")
                .font(.system(size: 11))
            Text("Localization: en, ja")
                .font(.system(size: 11))
                .padding(.bottom, 20)
            
            Text("Please feel free to contact me if you have any feedback.")
                .font(.system(size: 11))
            Button(action: {
                let url = URL(string: "mailto:" + MAIL_ADDRESS)!
                UIApplication.shared.open(url)
            }) {
                Text(MAIL_ADDRESS)
                    .font(.system(size: 12))
                    .padding(5)
            }
            
            Text(COPYRIGHT)
                .font(.system(size: 11))
                .foregroundColor(Color.init(UIColor.systemGray))
        }
        .navigationBarTitle("About App", displayMode: .inline)
    }
    
    func openURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            self.object.alertMessage = NSLocalizedString("Message_CantOpenURL", comment: "")
            self.object.alertDetail = ""
            self.object.isPopAlert = true
            return
        }
        guard UIApplication.shared.canOpenURL(url) else {
            self.object.alertMessage = NSLocalizedString("Message_CantOpenURL", comment: "")
            self.object.alertDetail = ""
            self.object.isPopAlert = true
            return
        }
        UIApplication.shared.open(url)
    }
}

fileprivate struct NumericSpecification: View {
    var body: some View {
        List {
            Section(header: Text("Header_GENERAL")) {
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_General1") }
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_General2") }
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_General3") }
            }
            Section(header: Text("Header_DOUBLE_TYPE")) {
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_DoubleType1") }
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_DoubleType2") }
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_DoubleType3") }
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_DoubleType4") }
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_DoubleType5") }
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_DoubleType6") }
            }
            Section(header: Text("Header_TYPE_SWITCHING")) {
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_TypeSwitching1") }
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_TypeSwitching2") }
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_TypeSwitching3") }
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_TypeSwitching4") }
                HStack(alignment: .top) { Image(systemName: "questionmark.circle"); Text("Specification_TypeSwitching5") }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("Numeric Specification", displayMode: .inline)
    }
}

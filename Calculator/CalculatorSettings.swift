//
//  CalculatorSettings.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI

let COPYRIGHT = "Copyright © 2021 manabapp. All rights reserved."
let URL_BASE = "https://manabapp.github.io/"
let URL_WEBPAGE = URL_BASE + "Apps/index.html"
let URL_WEBPAGE_JA = URL_BASE + "Apps/index_ja.html"

struct CalculatorSettings: View {
    @EnvironmentObject var object: CalculatorSharedObject
    
    var body: some View {
        List {
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
            }
            Section(header: Text("HEXADECIMAL LETTER").font(.system(size: 16, weight: .semibold)),
                    footer: Text("Footer_HEXADECIMAL_LETTER").font(.system(size: 12))) {
                Picker("", selection: self.$object.appSettingHexLetter) {
                    Text("Label_Lowercase").tag(CalculatorSharedObject.hexLetterLowercase)
                    Text("Label_Uppercase").tag(CalculatorSharedObject.hexLetterUppercase)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("UI STYLE").font(.system(size: 16, weight: .semibold)),
                    footer: Text("Footer_UI_Style").font(.system(size: 12))) {
                Picker("", selection: self.$object.appSettingUIStyle) {
                    Text("Label_Standard_type").tag(CalculatorSharedObject.uiStyleStandard)
                    Text("Label_Keyboard_type").tag(CalculatorSharedObject.uiStyleKeyboard)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("CHARACTER FONT").font(.system(size: 16, weight: .semibold)),
                    footer: VStack(alignment: .leading) {
                        Text("Footer_CHARACTER_FONT").font(.system(size: 12)).padding(.bottom, 50)
                        AboutApp()
                    }) {
                Picker("", selection: self.$object.appSettingCharacterFont) {
                    Text("Label_Small").tag(DataScreen.fontSmall)
                    Text("Label_Large").tag(DataScreen.fontLarge)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .listStyle(GroupedListStyle())
    }
}

fileprivate struct AboutApp: View {
    @EnvironmentObject var object: CalculatorSharedObject
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Calculator")
                .font(.system(size: 16, weight: .bold))
            Text("version " + object.appVersion)
                .font(.system(size: 13))
                .padding(.bottom, 2)
            Text("This app is programmer's calculator/converter.")
                .font(.system(size: 11))
            Text("Please see the website to learn more.")
                .font(.system(size: 11))
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
            Text(COPYRIGHT)
                .font(.system(size: 11))
                .foregroundColor(Color.init(UIColor.systemGray))
        }
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

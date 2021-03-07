//
//  CalculatorSharedObject.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI
import AudioToolbox

class CalculatorSharedObject: ObservableObject {
    static var isJa: Bool { Locale.preferredLanguages.first!.hasPrefix("ja") }
    static var isDark: Bool { UITraitCollection.current.userInterfaceStyle == .dark }
    
    static let uiStyleStandard: Int = 0
    static let uiStyleKeyboard: Int = 1
    static let hexLetterLowercase: Int = 0
    static let hexLetterUppercase: Int = 1
    
    var isStandard: Bool { self.appSettingUIStyle == Self.uiStyleStandard }
    var isUpper: Bool { self.appSettingHexLetter == Self.hexLetterUppercase }
    var isCharsLarge: Bool { self.appSettingCharacterFont == DataScreen.fontLarge }
    
    @Published var appVersion: String = ""
    @Published var deviceWidth: CGFloat = 0.0
    @Published var deviceHeight: CGFloat = 0.0
    @Published var isAlerting: Bool = false
    @Published var alertMessage: String = ""
    @Published var alertDetail: String = ""
    @Published var isPopAlert: Bool = false
    
    @Published var appSettingUIStyle: Int = CalculatorSharedObject.uiStyleStandard {
        didSet {
            UserDefaults.standard.set(appSettingUIStyle, forKey: "appSettingUIStyle")
        }
    }
    @Published var appSettingIdleTimerDisabled: Bool = false {
        didSet {
            UserDefaults.standard.set(appSettingIdleTimerDisabled, forKey: "appSettingIdleTimerDisabled")
            UIApplication.shared.isIdleTimerDisabled = appSettingIdleTimerDisabled
        }
    }
    @Published var appSettingSoundEffects: Bool = false {
        didSet {
            UserDefaults.standard.set(appSettingSoundEffects, forKey: "appSettingSoundEffects")
        }
    }
    @Published var appSettingHexLetter: Int = CalculatorSharedObject.hexLetterLowercase {
        didSet {
            UserDefaults.standard.set(appSettingHexLetter, forKey: "appSettingHexLetter")
        }
    }
    @Published var appSettingCharacterFont: Int = DataScreen.fontSmall {
        didSet {
            UserDefaults.standard.set(appSettingCharacterFont, forKey: "appSettingCharacterFont")
        }
    }
    
    func sound(isError: Bool = false) {
        if appSettingSoundEffects {
            AudioServicesPlaySystemSound(SystemSoundID(isError ? 1053 : 1104)) //Sounds
//            AudioServicesPlaySystemSound(SystemSoundID(isError ? 1161 : 1519)) //Vibrates
        }
    }
    init() {
        CalculatorUNIXTime.initTime()
        appSettingUIStyle = UserDefaults.standard.integer(forKey: "appSettingUIStyle")
        appSettingIdleTimerDisabled = UserDefaults.standard.bool(forKey: "appSettingIdleTimerDisabled")
        appSettingSoundEffects = UserDefaults.standard.bool(forKey: "appSettingSoundEffects")
        appSettingHexLetter = UserDefaults.standard.integer(forKey: "appSettingHexLetter")
        appSettingCharacterFont = UserDefaults.standard.integer(forKey: "appSettingCharacterFont")
        if let string = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String { appVersion = string }
        let width = CGFloat(UIScreen.main.bounds.width)
        let height = CGFloat(UIScreen.main.bounds.height)
        deviceWidth = width < height ? width : height
        deviceHeight = width < height ? height : width
        DataScreen.initSize(width: deviceWidth, height: deviceHeight)
        Bbody.initSize(width: deviceWidth, height: deviceHeight)
        HorizontalBbody.initSize(width: deviceWidth, height: deviceHeight)
        ByteField.initSize(width: deviceWidth, height: deviceHeight)
    }
}

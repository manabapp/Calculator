//
//  CalculatorSharedObject.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI
import AudioToolbox
import StoreKit

class CalculatorSharedObject: ObservableObject {
    static var isJa: Bool { Locale.preferredLanguages.first!.hasPrefix("ja") }
    static var isDark: Bool { UITraitCollection.current.userInterfaceStyle == .dark }
    
    static let uiStyleStandard: Int = 0
    static let uiStyleKeyboard: Int = 1
    static let hexLetterLowercase: Int = 0
    static let hexLetterUppercase: Int = 1
    
    var isStandard: Bool { self.appSettingUIStyle == Self.uiStyleStandard }
    var isUpper: Bool { self.appSettingHexLetter == Self.hexLetterUppercase }
    var isCharsLarge: Bool { self.charactersFont == DataScreen.fontLarge }
    
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
    @Published var appSetting1000Separator: Bool = false {
        didSet {
            UserDefaults.standard.set(appSetting1000Separator, forKey: "appSetting1000Separator")
        }
    }
    @Published var appSettingHexLetter: Int = CalculatorSharedObject.hexLetterLowercase {
        didSet {
            UserDefaults.standard.set(appSettingHexLetter, forKey: "appSettingHexLetter")
        }
    }
    
    @Published var numericMode: Int = CalculatorNumeric.modeD {
        didSet {
            UserDefaults.standard.set(numericMode, forKey: "numericMode")
        }
    }
    @Published var unixTimeMode: Int = CalculatorUNIXTime.modeLocal {
        didSet {
            UserDefaults.standard.set(unixTimeMode, forKey: "unixTimeMode")
        }
    }
    @Published var byteFieldsClosed: Bool = false {
        didSet {
            UserDefaults.standard.set(byteFieldsClosed, forKey: "byteFieldsClosed")
        }
    }
    @Published var charactersFont: Int = DataScreen.fontSmall {
        didSet {
            UserDefaults.standard.set(charactersFont, forKey: "charactersFont")
        }
    }

    func sound(isError: Bool = false) {
        if appSettingSoundEffects {
            AudioServicesPlaySystemSound(SystemSoundID(isError ? 1053 : 1104)) //Sounds
//            AudioServicesPlaySystemSound(SystemSoundID(isError ? 1161 : 1519)) //Vibrates
        }
        if isError {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    func alert(_ message: String) {
        self.alertMessage = message
        self.isAlerting = true
        DispatchQueue.global().async {
            sleep(1)
            DispatchQueue.main.async {
                self.isAlerting = false
            }
        }
    }

    init() {
        CalculatorUNIXTime.initTime()
        appSettingUIStyle = UserDefaults.standard.integer(forKey: "appSettingUIStyle")
        appSettingIdleTimerDisabled = UserDefaults.standard.bool(forKey: "appSettingIdleTimerDisabled")
        appSettingSoundEffects = UserDefaults.standard.bool(forKey: "appSettingSoundEffects")
        appSetting1000Separator = UserDefaults.standard.bool(forKey: "appSetting1000Separator")
        appSettingHexLetter = UserDefaults.standard.integer(forKey: "appSettingHexLetter")
        
        numericMode = UserDefaults.standard.integer(forKey: "numericMode")
        unixTimeMode = UserDefaults.standard.integer(forKey: "unixTimeMode")
        byteFieldsClosed = UserDefaults.standard.bool(forKey: "byteFieldsClosed")
        charactersFont = UserDefaults.standard.integer(forKey: "charactersFont")
        
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

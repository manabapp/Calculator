//
//  CalculatorSharedObject.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI
import AudioToolbox
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

let SOUND_TYPE_TAP: Int = 0
let SOUND_TYPE_ENTER: Int = 1
let SOUND_TYPE_ERROR: Int = 2
let SOUND_TYPE_COPY: Int = 3
let SOUND_TYPE_OPEN_CLOSE: Int = 4

class CalculatorSharedObject: ObservableObject {
    static var soundIdRingError: SystemSoundID = 0
    static var soundIdRingCopy: SystemSoundID = 0
    static var soundIdRingOpenClose: SystemSoundID = 0
    static var isJa: Bool { Locale.preferredLanguages.first!.hasPrefix("ja") }
    static var isDark: Bool { UITraitCollection.current.userInterfaceStyle == .dark }
    static var canCustomVibrate: Bool { CustomVibration.hapticEngine != nil }
    
    static let themeStandard: Int = 0
    static let themeProgrammer: Int = 1
    static let hexLetterLowercase: Int = 0
    static let hexLetterUppercase: Int = 1
    
    var isStandard: Bool { self.appSettingTheme == Self.themeStandard }
    var isCharsLarge: Bool { self.charactersFont == DataScreen.fontLarge }
    
    @Published var appVersion: String = ""
    @Published var deviceWidth: CGFloat = 0.0
    @Published var deviceHeight: CGFloat = 0.0
    @Published var isAlerting: Bool = false
    @Published var alertMessage: String = ""
    @Published var alertDetail: String = ""
    @Published var isPopAlert: Bool = false
    
    @Published var appSettingTheme: Int = CalculatorSharedObject.themeStandard {
        didSet {
            UserDefaults.standard.set(appSettingTheme, forKey: "appSettingTheme")
        }
    }
    @Published var appSetting1000Separator: Bool = false {
        didSet {
            UserDefaults.standard.set(appSetting1000Separator, forKey: "appSetting1000Separator")
        }
    }
    @Published var appSettingUppercaseLetter: Bool = false {
        didSet {
            UserDefaults.standard.set(appSettingUppercaseLetter, forKey: "appSettingUppercaseLetter")
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
    @Published var appSettingVibration: Bool = false {
        didSet {
            UserDefaults.standard.set(appSettingVibration, forKey: "appSettingVibration")
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
    
    func sound(_ type: Int = SOUND_TYPE_TAP) {
        //ref:
        // https://dev.classmethod.jp/articles/ios-systemsound/
        // https://qiita.com/flankids/items/ae607c5fe8917f960cba
        // https://qiita.com/hideji2/items/e7ed482ccffef2c0f66c
        if appSettingSoundEffects {
            switch type {
            case SOUND_TYPE_TAP:        AudioServicesPlaySystemSound(SystemSoundID(1104))
            case SOUND_TYPE_ENTER:      AudioServicesPlaySystemSound(SystemSoundID(1105))
            case SOUND_TYPE_ERROR:      AudioServicesPlaySystemSound(Self.soundIdRingError) //SystemSoundID:1053
            case SOUND_TYPE_COPY:       AudioServicesPlaySystemSound(Self.soundIdRingCopy) //SystemSoundID:1114
            case SOUND_TYPE_OPEN_CLOSE: AudioServicesPlaySystemSound(Self.soundIdRingOpenClose) //SystemSoundID:1100
            default:                    fatalError("CalculatorSharedObject.sound: unexpected type: \(type)")
            }
            if appSettingVibration {
                switch type {
                case SOUND_TYPE_TAP:
                    if Self.canCustomVibrate {
                        CustomVibration.playHapticEngine(intensityValue: 0.5, sharpnessValue: 1.0, durationValue: 0.0, sustainedValue: 0)
                    }
                    else {
                        AudioServicesPlaySystemSound(SystemSoundID(1519))
                    }
                case SOUND_TYPE_ENTER:
                    if Self.canCustomVibrate {
                        CustomVibration.playHapticEngine(intensityValue: 0.7, sharpnessValue: 0.9, durationValue: 0.0, sustainedValue: 0)
                    }
                    else {
                        AudioServicesPlaySystemSound(SystemSoundID(1519))
                    }
                case SOUND_TYPE_ERROR:
                    if Self.canCustomVibrate {
                        CustomVibration.playHapticEngine(intensityValue: 0.7, sharpnessValue: 0.5, durationValue: 0.2, sustainedValue: 1)
                    }
                    else {
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    }
                case SOUND_TYPE_COPY:
                    AudioServicesPlaySystemSound(SystemSoundID(1161))
                case SOUND_TYPE_OPEN_CLOSE:
                    AudioServicesPlaySystemSound(SystemSoundID(1161))
                default:
                    fatalError("CalculatorSharedObject.sound: unexpected type: \(type)")
                }
            }
        }
#if !DEBUG
        if type == SOUND_TYPE_ERROR {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
#endif
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
        appSettingTheme = UserDefaults.standard.integer(forKey: "appSettingTheme")
        appSetting1000Separator = UserDefaults.standard.bool(forKey: "appSetting1000Separator")
        appSettingUppercaseLetter = UserDefaults.standard.bool(forKey: "appSettingUppercaseLetter")
        appSettingIdleTimerDisabled = UserDefaults.standard.bool(forKey: "appSettingIdleTimerDisabled")
        appSettingSoundEffects = UserDefaults.standard.bool(forKey: "appSettingSoundEffects")
        appSettingVibration = UserDefaults.standard.bool(forKey: "appSettingVibration")
        
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
        
        CustomVibration.initHapticEngine()
        let soundUrlError = NSURL(fileURLWithPath: "/System/Library/Audio/UISounds/SIMToolkitNegativeACK.caf")
        let soundUrlCopy = NSURL(fileURLWithPath: "/System/Library/Audio/UISounds/end_record.caf")
        let soundUrlOpenClose = NSURL(fileURLWithPath: "/System/Library/Audio/UISounds/lock.caf")
        AudioServicesCreateSystemSoundID(soundUrlError, &Self.soundIdRingError)
        AudioServicesCreateSystemSoundID(soundUrlCopy, &Self.soundIdRingCopy)
        AudioServicesCreateSystemSoundID(soundUrlOpenClose, &Self.soundIdRingOpenClose)
    }
}

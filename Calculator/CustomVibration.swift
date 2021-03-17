//
//  CustomVibration.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/14.
//

import Foundation
import CoreHaptics

public class CustomVibration: NSObject {
    public static var hapticEngine: CHHapticEngine? = nil
    
    public static func initHapticEngine() {
        do {
            hapticEngine = try CHHapticEngine()
            hapticEngine?.isAutoShutdownEnabled = true
            try hapticEngine?.start()
        } catch {
#if DEBUG
            print("Vibration.initHapticEngine failed")
#endif
            hapticEngine = nil
        }
    }
    
    public static func playHapticEngine(intensityValue: Float, sharpnessValue: Float, durationValue: Float, sustainedValue: Float) {
        guard hapticEngine != nil else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensityValue)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpnessValue)
        let sustained = CHHapticEventParameter(parameterID: .sustained, value: sustainedValue)
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness, sustained], relativeTime: 0, duration: TimeInterval(durationValue))
        
        do {
            let hapticPattern = try CHHapticPattern(events: [event], parameters: [])
            let hapticPlayer = try hapticEngine?.makePlayer(with: hapticPattern)
            try hapticPlayer?.start(atTime: 0)
        } catch {
#if DEBUG
            print("Vibration.playHapticEngine failed")
#endif
        }
    }
}

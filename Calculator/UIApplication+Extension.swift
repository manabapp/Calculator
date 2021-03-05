//
//  UIApplication+Extension.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/05.
//

import SwiftUI

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

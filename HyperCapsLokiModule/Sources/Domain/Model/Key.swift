//
//  Key.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation
import Cocoa
import Carbon

/// Type alias for HID usage codes.
typealias HIDUsageCode = Int

/// Enum defining all supported keys with their corresponding HID usage and Carbon key codes.
public enum Key: String, CaseIterable, Hashable, Identifiable, Sendable {
  public var id: Self { self }
  
  case capsLock = "caps lock"
  case leftCommand = "left command"
  case leftOption = "left option"
  case leftShift = "left shift"
  case leftControl = "left control"
  case rightCommand = "right command"
  case rightOption = "right option"
  case rightShift = "right shift"
  case rightControl = "right control"
  case menuKeyboard = "menu keyboard"
  case f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12,
       f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24
  
  public var symbol: String {
    switch self {
      case .leftCommand: "⌘"
      case .leftOption: "⌥"
      case .leftControl: "⌃"
      case .leftShift: "⇧"
      default: ""
    }
  }
  
  public var alias: String {
    switch self {
      case .leftCommand: "meta"
      case .leftOption: "super"
      case .leftControl: "hyper"
      case .leftShift: "shift"
      default: ""
    }
  }
  
  /// Supported HID Keyboard Usage Codes with their corresponding key names.
  ///
  /// https://developer.apple.com/documentation/hiddriverkit/keyboard-or-keypad-enum
  ///
  var hidUsageKeyboardCode: HIDUsageCode {
    switch self {
      case .capsLock:     kHIDUsage_KeyboardCapsLock
      case .leftCommand:  kHIDUsage_KeyboardLeftGUI
      case .leftOption:   kHIDUsage_KeyboardLeftAlt
      case .leftShift:    kHIDUsage_KeyboardLeftShift
      case .leftControl:  kHIDUsage_KeyboardLeftControl
      case .rightCommand: kHIDUsage_KeyboardRightGUI
      case .rightOption:  kHIDUsage_KeyboardRightAlt
      case .rightShift:   kHIDUsage_KeyboardRightShift
      case .rightControl: kHIDUsage_KeyboardRightControl
      case .menuKeyboard: kHIDUsage_KeyboardMenu
        
      case .f1:   kHIDUsage_KeyboardF1
      case .f2:   kHIDUsage_KeyboardF2
      case .f3:   kHIDUsage_KeyboardF3
      case .f4:   kHIDUsage_KeyboardF4
      case .f5:   kHIDUsage_KeyboardF5
      case .f6:   kHIDUsage_KeyboardF6
      case .f7:   kHIDUsage_KeyboardF7
      case .f8:   kHIDUsage_KeyboardF8
      case .f9:   kHIDUsage_KeyboardF9
      case .f10:  kHIDUsage_KeyboardF10
      case .f11:  kHIDUsage_KeyboardF11
      case .f12:  kHIDUsage_KeyboardF12
      case .f13:  kHIDUsage_KeyboardF13
      case .f14:  kHIDUsage_KeyboardF14
      case .f15:  kHIDUsage_KeyboardF15
      case .f16:  kHIDUsage_KeyboardF16
      case .f17:  kHIDUsage_KeyboardF17
      case .f18:  kHIDUsage_KeyboardF18
      case .f19:  kHIDUsage_KeyboardF19
      case .f20:  kHIDUsage_KeyboardF20
      case .f21:  kHIDUsage_KeyboardF21
      case .f22:  kHIDUsage_KeyboardF22
      case .f23:  kHIDUsage_KeyboardF23
      case .f24:  kHIDUsage_KeyboardF24
    }
  }
  
  /// Returns the corresponding Carbon (HIToolbox) key code for the key.
  var carbonKeyCode: CGKeyCode {
    switch self {
      case .capsLock:     CGKeyCode(kVK_CapsLock)
      case .leftCommand:  CGKeyCode(kVK_Command)
      case .leftOption:   CGKeyCode(kVK_Option)
      case .leftShift:    CGKeyCode(kVK_Shift)
      case .leftControl:  CGKeyCode(kVK_Control)
      case .rightCommand: CGKeyCode(kVK_RightCommand)
      case .rightOption:  CGKeyCode(kVK_RightOption)
      case .rightShift:   CGKeyCode(kVK_RightShift)
      case .rightControl: CGKeyCode(kVK_RightControl)
      case .menuKeyboard: CGKeyCode(kVK_ContextualMenu)
        
      case .f1:  CGKeyCode(kVK_F1)
      case .f2:  CGKeyCode(kVK_F2)
      case .f3:  CGKeyCode(kVK_F3)
      case .f4:  CGKeyCode(kVK_F4)
      case .f5:  CGKeyCode(kVK_F5)
      case .f6:  CGKeyCode(kVK_F6)
      case .f7:  CGKeyCode(kVK_F7)
      case .f8:  CGKeyCode(kVK_F8)
      case .f9:  CGKeyCode(kVK_F9)
      case .f10: CGKeyCode(kVK_F10)
      case .f11: CGKeyCode(kVK_F11)
      case .f12: CGKeyCode(kVK_F12)
      case .f13: CGKeyCode(kVK_F13)
      case .f14: CGKeyCode(kVK_F14)
      case .f15: CGKeyCode(kVK_F15)
      case .f16: CGKeyCode(kVK_F16)
      case .f17: CGKeyCode(kVK_F17)
      case .f18: CGKeyCode(kVK_F18)
      case .f19: CGKeyCode(kVK_F19)
      case .f20: CGKeyCode(kVK_F20)
        
      default:
        // HID and Carbon don't align for non-function keys, use default mapping
        CGKeyCode(hidUsageKeyboardCode & 0xFFFF)
    }
  }
}

// MARK: - All Hyperkey Sequence Keys and corresponding CGEventFlags
extension Key {
  static let allHyperkeySequenceKeys: [Key] = [
    .leftCommand,
    .leftOption,
    .leftControl,
    .leftShift
  ]
  
  static var allHyperkeySequenceEventFlags: [Key: CGEventFlags] {
    Dictionary(
      uniqueKeysWithValues:
        allHyperkeySequenceKeys
        .compactMap { key in
          switch key {
            case .leftCommand: (key, .maskCommand)
            case .leftOption: (key, .maskAlternate)
            case .leftControl: (key, .maskControl)
            case .leftShift: (key, .maskShift)
            default: nil
          }
        }
    )
  }
}

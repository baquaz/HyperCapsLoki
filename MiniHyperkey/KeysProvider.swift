//
//  KeysUsageKeyboard.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 25/01/2025.
//

import Foundation
import IOKit.hid
import Cocoa
import Carbon


/// Provides mappings and utilities for keyboard keys and their HID usage codes
struct KeysProvider {
  
  /// Type alias for HID usage codes.
  typealias HIDUsageCode = Int
  
  /// Enum defining all supported keys with their corresponding HID usage and Carbon key codes.
  enum Key: String, CaseIterable {
    case capsLock = "caps lock"
    case leftCommand = "left command"
    case leftOption = "left option"
    case leftShift = "left shift"
    case leftControl = "left control"
    case rightCommand = "right command"
    case rightOption = "right option"
    case rightShift = "right shift"
    case rightControl = "right control"
    case menuPC = "menu (PC)"
    case f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12,
         f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24
    
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
        case .menuPC:       kHIDUsage_KeyboardMenu
          
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
        case .menuPC:       CGKeyCode(kVK_ContextualMenu)
          
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
  
  
  // MARK: - Init
  static let shared = KeysProvider()
  
  private init(){}
  
  func getExpectedKeyCode(for key: Key) -> CGKeyCode {
    guard let hidCode = hidUsageCode(for: key) else {
      fatalError("Key mapping for \(key.rawValue) not found.")
    }
    
    // Convert HID usage code into CGKeyCode
    return CGKeyCode(hidCode & 0xFFFF) // Mask to extract correct key code
  }
  
  // MARK: - Create
  
  /// Combines HID _Usage Page_ with _Usage ID_ into single integer
  ///
  /// example:
  /// ```
  /// 0x7  (usage page)
  ///   | 0000000
  ///   | 39 (usage ID)
  /// ```
  /// Which is `0x07` in the upper nibble of the usage field and `0x39` in the lower nibble—forming the combined 64-bit usage number.
  ///
  /// - Parameters:
  ///   - page: Usage Page - tells the system which category of HID usages you're referencing
  ///   (e.g. keyboard usages have page `0x07`).
  ///   - usage: Usage ID - identifies the specific key within that usage page (e.g. Caps Lock is `0x39`).
  /// - Returns: full **Usage** value
  func makeHIDUsageNumber(page: Int, usage: Int) -> Int {
    (page << 32) | usage
  }
  
  // MARK: - Read
  
  /// Retrieves the HID usage code for a given key name.
  ///
  /// - Parameter key: The `KeyName` for which the HID usage code is required.
  /// - Returns: The corresponding HID usage code, or `nil` if the key is unsupported.
  ///
  func hidUsageCode(for key: Key) -> HIDUsageCode? {
    key.hidUsageKeyboardCode
  }
  
  /// Retrieves the key name for a given HID usage code.
  ///
  /// - Parameter code: The HID usage code to search for.
  /// - Returns: The corresponding `KeyName`, or `nil` if the code is not recognized.
  ///
  func keyName(for code: HIDUsageCode) -> String? {
    Key.allCases.first(where: { $0.hidUsageKeyboardCode == code })?.rawValue
  }
  
  /// Retrieves all possible HID Keyboard Usages
  ///
  /// - Returns: HID Keyboard Usages
  ///
  func retrieveKeyboardUsages() -> [String: Int] {
    var keyMapping: [String: Int] = [:]
    
    // HID Manager
    let hidManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    
    let matchingDict: [String: Any] = [:] // Match all devices
    IOHIDManagerSetDeviceMatching(hidManager, matchingDict as CFDictionary)
    
    // Open HID Manager
    let openResult = IOHIDManagerOpen(hidManager, IOOptionBits(kIOHIDOptionsTypeNone))
    if openResult != kIOReturnSuccess {
      print("failed to open HID Manager with error: \(openResult)")
      return keyMapping
    }
    
    // Get All Matching Devices
    guard let devices = IOHIDManagerCopyDevices(hidManager) as? Set<IOHIDDevice> else {
      print("No HID devices found.")
      return keyMapping
    }
    
    print("Devices found: \(devices.count)")
    for device in devices {
      // Print Device Properties
      if let product = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String {
        print("found Device: \(product)")
      }
      
      // Get All Elements for the Device
      guard let elements = IOHIDDeviceCopyMatchingElements(device, nil, IOOptionBits(kIOHIDOptionsTypeNone)) as? [IOHIDElement] else {
        continue
      }
      
      for element in elements {
        let usagePage = IOHIDElementGetUsagePage(element)
        let usage = IOHIDElementGetUsage(element)
        if usagePage == kHIDPage_KeyboardOrKeypad {
          keyMapping["Usage \(usage)"] = Int(usage)
          print("Keyboard Element - Usage Page: \(usagePage), Usage: \(usage)")
        }
      }
    }
    
    return keyMapping
  }
  
  // MARK: - Transform
  
  /// Transform a collection of keys to their HID usage codes using a Set.
  ///
  /// - Parameter keys: A set of `KeyName`.
  /// - Returns: A set of corresponding HID usage codes.
  ///
  func transform(keyNames: Set<Key>) -> Set<HIDUsageCode> {
    Set(Key.allCases.compactMap( { hidUsageCode(for: $0) } ))
  }
  
  /// Transform a collection of HID usage codes to their corresponding key names using a Set.
  ///
  /// - Parameter codes: A set of HID usage codes.
  /// - Returns: A set of corresponding `KeyName`.
  ///
  func transform(usageCodes codes: Set<HIDUsageCode>) -> Set<String> {
    Set(codes.compactMap( { keyName(for: $0) } ))
  }
  
  // MARK: - Operations
  
  /// Computes the intersection of two sets of key names.
  ///
  /// - Parameters:
  ///   - keys1: The first set of `KeyName`.
  ///   - keys2: The second set of `KeyName`.
  /// - Returns: A set of keys common to both input sets.
  ///
  func intersection(of keys1: Set<Key>, and keys2: Set<Key>) -> Set<Key> {
    keys1.intersection(keys2)
  }
  
  /// Computes the union of two sets of key names.
  ///
  /// - Parameters:
  ///   - keys1: The first set of `KeyName`.
  ///   - keys2: The second set of `KeyName`.
  /// - Returns: A set containing all keys from both input sets.
  ///
  func union(of keys1: Set<Key>, and keys2: Set<Key>) -> Set<Key> {
    keys1.union(keys2)
  }
}



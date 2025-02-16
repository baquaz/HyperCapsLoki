//
//  KeysUsageKeyboard.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 25/01/2025.
//

import Foundation
import IOKit.hid


/// Provides mappings and utilities for keyboard keys and their HID usage codes
struct KeysProvider {
  
  enum KeyName: String {
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
    case f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12
    case f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24
  }
  
  /// Type alias for HID usage codes.
  typealias HIDUsageCode = Int
  
  /// Supported HID Keyboard Usage Codes with their corresponding key names.
  ///
  /// https://developer.apple.com/documentation/hiddriverkit/keyboard-or-keypad-enum
  ///
  private let hidUsageKeyboardCodes: [KeyName: HIDUsageCode] = [
    .capsLock: kHIDUsage_KeyboardCapsLock,
    
    .leftCommand: kHIDUsage_KeyboardLeftGUI,
    .leftOption: kHIDUsage_KeyboardLeftAlt,
    .leftShift: kHIDUsage_KeyboardLeftShift,
    .leftControl: kHIDUsage_KeyboardLeftControl,
    
    .rightCommand: kHIDUsage_KeyboardRightGUI,
    .rightOption: kHIDUsage_KeyboardRightAlt,
    .rightShift: kHIDUsage_KeyboardRightShift,
    .rightControl: kHIDUsage_KeyboardRightControl,
    
    .menuPC: kHIDUsage_KeyboardMenu,
    
    .f1: kHIDUsage_KeyboardF1,
    .f2: kHIDUsage_KeyboardF2,
    .f3: kHIDUsage_KeyboardF3,
    .f4: kHIDUsage_KeyboardF4,
    .f5: kHIDUsage_KeyboardF5,
    .f6: kHIDUsage_KeyboardF6,
    .f7: kHIDUsage_KeyboardF7,
    .f8: kHIDUsage_KeyboardF8,
    .f9: kHIDUsage_KeyboardF9,
    .f10: kHIDUsage_KeyboardF10,
    .f11: kHIDUsage_KeyboardF11,
    .f12: kHIDUsage_KeyboardF12,
    .f13: kHIDUsage_KeyboardF13,
    .f14: kHIDUsage_KeyboardF14,
    .f15: kHIDUsage_KeyboardF15,
    .f16: kHIDUsage_KeyboardF16,
    .f17: kHIDUsage_KeyboardF17,
    .f18: kHIDUsage_KeyboardF18,
    .f19: kHIDUsage_KeyboardF19,
    .f20: kHIDUsage_KeyboardF20,
    .f21: kHIDUsage_KeyboardF21,
    .f22: kHIDUsage_KeyboardF22,
    .f23: kHIDUsage_KeyboardF23,
    .f24: kHIDUsage_KeyboardF24
  ]
  
  
  // MARK: - Init
  static let shared = KeysProvider()
  
  private init(){}
  
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
  func hidUsageCode(for key: KeyName) -> HIDUsageCode? {
    hidUsageKeyboardCodes[key]
  }
  
  /// Retrieves the key name for a given HID usage code.
  ///
  /// - Parameter code: The HID usage code to search for.
  /// - Returns: The corresponding `KeyName`, or `nil` if the code is not recognized.
  ///
  func keyName(for code: HIDUsageCode) -> KeyName? {
    hidUsageKeyboardCodes.first(where: { $0.value == code })?.key
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
  func transform(keyNames: Set<KeyName>) -> Set<HIDUsageCode> {
    Set(keyNames.compactMap( { hidUsageCode(for: $0) } ))
  }
  
  /// Transform a collection of HID usage codes to their corresponding key names using a Set.
  ///
  /// - Parameter codes: A set of HID usage codes.
  /// - Returns: A set of corresponding `KeyName`.
  ///
  func transform(usageCodes codes: Set<HIDUsageCode>) -> Set<KeyName> {
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
  func intersection(of keys1: Set<KeyName>, and keys2: Set<KeyName>) -> Set<KeyName> {
    keys1.intersection(keys2)
  }
  
  /// Computes the union of two sets of key names.
  ///
  /// - Parameters:
  ///   - keys1: The first set of `KeyName`.
  ///   - keys2: The second set of `KeyName`.
  /// - Returns: A set containing all keys from both input sets.
  ///
  func union(of keys1: Set<KeyName>, and keys2: Set<KeyName>) -> Set<KeyName> {
    keys1.union(keys2)
  }
}



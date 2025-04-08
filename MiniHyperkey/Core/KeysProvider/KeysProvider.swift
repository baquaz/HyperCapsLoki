//
//  KeysUsageKeyboard.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 25/01/2025.
//

import Foundation
import IOKit.hid
import Cocoa

/// Provides mappings and utilities for keyboard keys and their HID usage codes
struct KeysProvider {
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
  
  /// Retrieves the _Carbon_ key code for a given key name.
  ///
  /// - Parameter key: The `Key` for which the Carbon key code is required.
  /// - Returns: The corresponding `CGKeyCode`, or `nil` if the key is unsupported.
  func carbonKeyCode(for key: Key) -> CGKeyCode? {
    key.carbonKeyCode
  }
  
  /// Retrieves the HID usage code for a given key name.
  ///
  /// - Parameter key: The `Key` name for which the HID usage code is required.
  /// - Returns: The corresponding HID usage code, or `nil` if the key is unsupported.
  ///
  func hidUsageCode(for key: Key) -> HIDUsageCode? {
    key.hidUsageKeyboardCode
  }
  
  /// Retrieves the key name for a given HID usage code.
  ///
  /// - Parameter code: The HID usage code to search for.
  /// - Returns: The corresponding `Key` name, or `nil` if the code is not recognized.
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
  func transform(keys: Set<Key>) -> Set<HIDUsageCode> {
    Set(keys.compactMap( { hidUsageCode(for: $0) } ))
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



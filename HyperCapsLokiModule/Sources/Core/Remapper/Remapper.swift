//
//  Remapper.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 26/01/2025.
//

import Foundation

public protocol RemapExecutor {
  func remapUserKeyMappingCapsLock(using key: Key)
  func resetUserKeyMappingCapsLock()
}

public struct Remapper: RemapExecutor {
  
  let keysProvider: KeysProvider
  
  private var capsLockUsage: Int {
    keysProvider.makeHIDUsageNumber(page: kHIDPage_KeyboardOrKeypad, usage: kHIDUsage_KeyboardCapsLock)
  }
  
  // MARK: - Init
  init(keysProvider: KeysProvider = .shared) {
    self.keysProvider = keysProvider
  }
  
  // MARK: - Remap
  public func remapUserKeyMappingCapsLock(using key: Key) {
    guard let destinationUsageCode = keysProvider.hidUsageCode(for: key) else {
      Applog.print(tag: .critical, context: .keyRemapping,
                   key.rawValue, "key not found.")
      return
    }
    let destinationUsage = keysProvider.makeHIDUsageNumber(page: kHIDPage_KeyboardOrKeypad, usage: destinationUsageCode)
    
    Applog.print(context: .keyRemapping,"Remapping Caps Lock...")
        
    var userKeyMapping = getCurrentUserKeyMapping()
    
    // remove any existing Caps Lock remap
    removeCapsLockRemapping(from: &userKeyMapping)
    
    // add new remap
    userKeyMapping.append([
      "HIDKeyboardModifierMappingSrc": capsLockUsage, // Caps Lock (0x700000039)
      "HIDKeyboardModifierMappingDst": destinationUsage
    ])
    
    do {
      let data = try JSONSerialization.data(withJSONObject: userKeyMapping, options: [])
      if let jsonString = String(data: data, encoding: .utf8) {
        let command = "hidutil property --set '{\"UserKeyMapping\": \(jsonString)}'"
        
        _ = shell(command)
        Applog.print(context: .keyRemapping,
                     "Caps Lock remapped to \(key.rawValue).")
      }
    } catch {
      Applog.print(tag: .critical, context: .keyRemapping,
                   "Error serializing UserKeyMapping JSON: \(error)")
    }
  }
  
  // MARK: - Reset
  public func resetUserKeyMappingCapsLock() {
    var userKeyMapping = getCurrentUserKeyMapping()
    
    // remove any existing Caps Lock remap
    removeCapsLockRemapping(from: &userKeyMapping)
    
    do {
      let data = try JSONSerialization.data(withJSONObject: userKeyMapping, options: [])
      if let jsonString = String(data: data, encoding: .utf8) {
        let command = "hidutil property --set '{\"UserKeyMapping\": \(jsonString)}'"

        _ = shell(command)
        Applog.print(context: .keyRemapping, "Caps Lock remapping has been removed.")
      }
    } catch {
      Applog.print(tag: .critical, context: .keyRemapping,
                   "Error serializing UserKeyMapping JSON: \(error)")
    }
  }
  
  private func removeCapsLockRemapping(from userKeyMapping: inout [[String: Any]]) {
    let capsLockUsage = self.capsLockUsage
    
    userKeyMapping.removeAll {
      guard let src = $0["HIDKeyboardModifierMappingSrc"] else { return false }
      
      let intValue: Int? = {
        if let val = src as? Int {
          val
        } else if let val = src as? NSNumber {
          val.intValue
        } else if let val = src as? String {
          Int(val)
        } else {
          nil
        }
      }()
      
      return intValue == capsLockUsage
    }
  }
  
  // MARK: - Current User Key Mapping
  private func getCurrentUserKeyMapping() -> [[String: Any]] {
    let command = "hidutil property --get \"UserKeyMapping\""
    let output = shell(command)
    
    guard let data = output.data(using: .utf8) else {
      Applog.print(tag: .critical, context: .keyRemapping,
                   "Failed to convert shell output to data")
      return []
    }
    do {
      let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
      
      if let mappings = plist as? [[String: Any]] {
        return mappings
        
      } else if let dict = plist as? [String: Any],
                let mappings = dict["UserKeyMapping"] as? [[String: Any]] {
        return mappings
      } else {
        return []
      }
    } catch {
      Applog.print(tag: .critical, context: .keyRemapping,
                   error.localizedDescription)
      return []
    }
  }
  
  // MARK: - Shell Executor
  private func shell(_ command: String) -> String {
    let task = Process()
    
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    
    return output
  }
}

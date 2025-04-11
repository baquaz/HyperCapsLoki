//
//  Remapper.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 26/01/2025.
//

import Foundation

protocol RemapExecutor {
  func remapUserKeyMappingCapsLock(using key: Key?)
  func resetUserKeyMapping()
}

struct Remapper: RemapExecutor {
  
  let keysProvider: KeysProvider
  
  // MARK: - Init
  init(keysProvider: KeysProvider = .shared) {
    self.keysProvider = keysProvider
  }
  
  // MARK: - Remap
  func remapUserKeyMappingCapsLock(using key: Key?) {
    guard let key else { return }
    let capsLockUsage = keysProvider.makeHIDUsageNumber(page: kHIDPage_KeyboardOrKeypad, usage: kHIDUsage_KeyboardCapsLock)
    
    guard let destinationUsageCode = keysProvider.hidUsageCode(for: key) else {
      fatalError("\(key.rawValue) key not found.")
    }
    let destinationUsage = keysProvider.makeHIDUsageNumber(page: kHIDPage_KeyboardOrKeypad, usage: destinationUsageCode)
    
    print("🔍 Debug: Remapping Caps Lock to \(String(format: "0x%X", destinationUsage))")
        
    var userKeyMapping = getCurrentUserKeyMapping()

    // remove any existing Caps Lock remap
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
    
    // add new remap
    userKeyMapping.append([
      "HIDKeyboardModifierMappingSrc": capsLockUsage, // Caps Lock (0x700000039)
      "HIDKeyboardModifierMappingDst": destinationUsage
    ])
    
    do {
      let data = try JSONSerialization.data(withJSONObject: userKeyMapping, options: [])
      if let jsonString = String(data: data, encoding: .utf8) {
        let command = "hidutil property --set '{\"UserKeyMapping\": \(jsonString)}'"
        print("Executing command: \(command)")
        
        let output = shell(command)
        print("Command output: \(output)")
        print("Caps Lock remapped to \(key.rawValue).")
      }
    } catch {
      print("Error serializing JSON: \(error)")
    }
  }
  
  // MARK: - Reset
  func resetUserKeyMapping() {
    let command = "hidutil property --set '{\"UserKeyMapping\": []}'"
    print("Executing command to reset key mappings: \(command)")
    
    let output = shell(command)
    print("Command output: \(output)")
    print("Key mappings have been reset.")
  }
  
  // MARK: - Current User Key Mapping
  private func getCurrentUserKeyMapping() -> [[String: Any]] {
    let command = "hidutil property --get \"UserKeyMapping\""
    print("Executing command: \(command)")
    
    let output = shell(command)
    print("Command output: \(output)")
    
    guard let data = output.data(using: .utf8) else {
      fatalError("Failed to convert shell output to data")
    }
    do {
      let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
      
      if let mappings = plist as? [[String: Any]] {
        return mappings
        
      } else if let dict = plist as? [String: Any],
                let mappings = dict["UserKeyMapping"] as? [[String: Any]] {
        return mappings
      } else {
        fatalError("Unexpected plist structure: \(plist)")
      }
    } catch {
      fatalError(error.localizedDescription)
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

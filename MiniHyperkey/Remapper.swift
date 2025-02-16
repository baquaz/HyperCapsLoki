//
//  Remapper.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 26/01/2025.
//

import Foundation

protocol RemapExecutor {
  func remapUserKeyMappingCapsLock(using keyName: KeysProvider.KeyName)
  func resetUserKeyMapping()
}

struct Remapper: RemapExecutor {
  
  let keysProvider: KeysProvider
  
  // MARK: - Init
  init(keysProvider: KeysProvider = .shared) {
    self.keysProvider = keysProvider
  }
  
  func remapUserKeyMappingCapsLock(using keyName: KeysProvider.KeyName) {
    let capsLockUsage = keysProvider.makeHIDUsageNumber(page: kHIDPage_KeyboardOrKeypad, usage: kHIDUsage_KeyboardCapsLock)
    
    guard let destinationUsageCode = keysProvider.hidUsageCode(for: keyName) else {
      fatalError("\(keyName) key not found.")
    }
    let destinationUsage = keysProvider.makeHIDUsageNumber(page: kHIDPage_KeyboardOrKeypad, usage: destinationUsageCode)
    
    let userKeyMapping: [[String: Any]] = [
      ["HIDKeyboardModifierMappingSrc": capsLockUsage /*0x700000039*/, // Caps Lock
       "HIDKeyboardModifierMappingDst": destinationUsage]
    ]
    
    do {
      let data = try JSONSerialization.data(withJSONObject: userKeyMapping, options: [])
      if let jsonString = String(data: data, encoding: .utf8) {
        let command = "hidutil property --set '{\"UserKeyMapping\": \(jsonString)}'"
        print("Executing command: \(command)")
        let output = self.shell(command)
        print("Command output: \(output)")
        print("Caps Lock remapped to \(keyName).")
      }
    } catch {
      print("Error serializing JSON: \(error)")
    }
  }
  
  func resetUserKeyMapping() {
    let command = "hidutil property --set '{\"UserKeyMapping\": []}'"
    print("Executing command to reset key mappings: \(command)")
    
    let output = self.shell(command)
    print("Command output: \(output)")
    print("Key mappings have been reset.")
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

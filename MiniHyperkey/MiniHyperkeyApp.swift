//
//  MiniHyperkeyApp.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 29/12/2024.
//

import SwiftUI
import Cocoa
import IOKit.hid

@main
struct MiniHyperkeyApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    // Schedule a delayed Caps Lock remapping after 5 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
      print("Remapping Caps Lock to Hyperkey (Shift+Control+Option+Command) programmatically after 5 seconds")
      self.remapCapsLockToHyperkey()
    }
  }
  
  func remapCapsLockToHyperkey() {
    print("Remapping Caps Lock to Hyperkey (Shift+Control+Option+Command)")
  
    let userKeyMapping: [[String: Any]] = [
      ["HIDKeyboardModifierMappingSrc": 0x700000039, // Caps Lock
       "HIDKeyboardModifierMappingDst":0x700000004] // a key
    ]
  
    do {
      let data = try JSONSerialization.data(withJSONObject: userKeyMapping, options: [])
      if let jsonString = String(data: data, encoding: .utf8) {
        let command = "hidutil property --set '{\"UserKeyMapping\": \(jsonString)}'"
        print("Executing command: \(command)")
        DispatchQueue.global(qos: .userInitiated).async {
          let output = self.shell(command)
          print("Command output: \(output)")
          if output.isEmpty {
            print("Failed to remap Caps Lock to Hyperkey. Command output is empty.")
          } else {
            print("Caps Lock remapped to Hyperkey (Shift+Control+Option+Command).")
          }
        }
      }
    } catch {
      print("Error serializing JSON: \(error)")
    }
  }
  
  func shell(_ command: String) -> String {
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


/* Remapping Combination Keys */

//  func remapCapsLockToHyperkey() {
//    print("Remapping Caps Lock to Hyperkey")
//
//    let userKeyMapping: [[String: Any]] = [
//      ["HIDKeyboardModifierMappingSrc": 0x700000039, // Caps Lock
//       "HIDKeyboardModifierMappingDst": [
//        /*kHIDPage_KeyboardOrKeypad,*/ kHIDUsage_KeyboardLeftShift, // Shift
//        /*kHIDPage_KeyboardOrKeypad,*/ kHIDUsage_KeyboardLeftControl, // Control
//        /*kHIDPage_KeyboardOrKeypad,*/ kHIDUsage_KeyboardLeftAlt, // Option
//        /*kHIDPage_KeyboardOrKeypad,*/ kHIDUsage_KeyboardLeftGUI // Command
//       ]]
//    ]
//
//    do {
//      let data = try JSONSerialization.data(withJSONObject: userKeyMapping, options: [])
//      if let jsonString = String(data: data, encoding: .utf8) {
//        let command = "hidutil property --set '{\"UserKeyMapping\": \(jsonString)}'"
//        print("Executing command: \(command)")
//        let output = shell(command)
//        print("Command output: \(output)")
//        print("Caps Lock remapped to Hyperkey (Shift+Control+Option+Command).")
//      }
//    } catch {
//      print("Error serializing JSON: \(error)")
//    }
//  }





//@main
//struct MiniHyperkeyApp: App {
//  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//  
//  var body: some Scene {
//    WindowGroup {
//      ContentView()
//    }
//  }
//}
//
//class AppDelegate: NSObject, NSApplicationDelegate {
//  var hidManager: IOHIDManager?
//  
//  func applicationDidFinishLaunching(_ notification: Notification) {
//    setupHIDManager()
//    
//    // Schedule a delayed Caps Lock remapping after 5 seconds
//    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//      print("Remapping Caps Lock programmatically after 5 seconds")
//      self.remapCapsLock()
//    }
//  }
//  
//  func setupHIDManager() {
//    hidManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
//    
//    let matchingDict: [String: Any] = [kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
//                                           kIOHIDDeviceUsageKey: kHIDUsage_GD_Keyboard]
//    
//    IOHIDManagerSetDeviceMatching(hidManager!, matchingDict as CFDictionary)
//    IOHIDManagerRegisterInputValueCallback(hidManager!, { context, result, sender, value in
//      let element = IOHIDValueGetElement(value)
//      let scancode = IOHIDElementGetUsage(element)
//      let pressed = IOHIDValueGetIntegerValue(value)
//      print("Scancode: \(scancode), Pressed: \(pressed)")
//    }, nil)
//    
//    IOHIDManagerScheduleWithRunLoop(hidManager!, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
//    IOHIDManagerOpen(hidManager!, IOOptionBits(kIOHIDOptionsTypeNone))
//    print("HID Manager setup completed.")
//  }
//  
//  func remapCapsLock() {
//    print("Remapping Caps Lock")
//    
//    let userKeyMapping: [[String: Any]] = [
//      ["HIDKeyboardModifierMappingSrc": kHIDUsage_KeyboardCapsLock,
//       "HIDKeyboardModifierMappingDst": kHIDUsage_KeyboardEscape] // Example remap to Escape key
//    ]
//    
//    let data = try! JSONSerialization.data(withJSONObject: userKeyMapping, options: [])
//    let jsonString = String(data: data, encoding: .utf8)
//    
//    let command = "hidutil property --set '{\"UserKeyMapping\": \(jsonString!)}'"
//    print("Executing command: \(command)")
//    let output = shell(command)
//    print("Command output: \(output)")
//    
//    print("Caps Lock remapped.")
//  }
//  
//  func shell(_ command: String) -> String {
//    let task = Process()
//    task.launchPath = "/bin/bash"
//    task.arguments = ["-c", command]
//    
//    let pipe = Pipe()
//    task.standardOutput = pipe
//    task.launch()
//    
//    let data = pipe.fileHandleForReading.readDataToEndOfFile()
//    let output = String(data: data, encoding: .utf8) ?? ""
//    
//    return output
//  }
//}

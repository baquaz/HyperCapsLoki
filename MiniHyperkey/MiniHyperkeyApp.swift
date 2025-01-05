//
//  MiniHyperkeyApp.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 29/12/2024.
//

import IOKit.hid
import SwiftUI
import Cocoa

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
  var eventTap: CFMachPort?
  var isHyperkeyActive = false
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    // Reset previous key mappings
    resetHidutilMappings()
    
    // Remap Caps Lock to F14
    remapCapsLockToF14()
    
    // Set up event taps
    setupEventTap()
  }
  
  func resetHidutilMappings() {
    let command = "hidutil property --set '{\"UserKeyMapping\": []}'"
    print("Executing command to reset key mappings: \(command)")
    
    let output = self.shell(command)
    print("Command output: \(output)")
    print("Key mappings have been reset.")
  }
  
  func remapCapsLockToF14() {
    let userKeyMapping: [[String: Any]] = [
      ["HIDKeyboardModifierMappingSrc": 0x700000039, // Caps Lock
       "HIDKeyboardModifierMappingDst": 0x700000068] // F14
    ]
    
    do {
      let data = try JSONSerialization.data(withJSONObject: userKeyMapping, options: [])
      if let jsonString = String(data: data, encoding: .utf8) {
        let command = "hidutil property --set '{\"UserKeyMapping\": \(jsonString)}'"
        print("Executing command: \(command)")
        let output = self.shell(command)
        print("Command output: \(output)")
        print("Caps Lock remapped to F14.")
      }
    } catch {
      print("Error serializing JSON: \(error)")
    }
  }
  
  func setupEventTap() {
    let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
    eventTap = CGEvent.tapCreate(tap: .cgAnnotatedSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: CGEventMask(eventMask), callback: eventTapCallback, userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    
    if let eventTap = eventTap {
      let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
      CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
      CGEvent.tapEnable(tap: eventTap, enable: true)
      print("Event tap set up successfully")
    } else {
      print("Failed to create event tap")
    }
  }
  
  let eventTapCallback: CGEventTapCallBack = { (proxy, type, event, refcon) in
    let appDelegate = Unmanaged<AppDelegate>.fromOpaque(refcon!).takeUnretainedValue()
    return appDelegate.handleEventTap(proxy: proxy, type: type, event: event)
  }
  
  func handleEventTap(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
    if type == .keyDown || type == .keyUp {
      let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
      let flags = event.flags.rawValue
      
      print("Key code: \(keyCode), Flags: \(flags), Type: \(type == .keyDown ? "KeyDown" : "KeyUp")")
      
      // Handle F14 key press (remapped from Caps Lock)
      if keyCode == 0x68 { // F14
        if type == .keyDown {
          print("F14 key down intercepted")
          
          // Synthesize new events for the combination of keys
          if let shiftKeyDown = CGEvent(keyboardEventSource: nil, virtualKey: 56, keyDown: true),
             let controlKeyDown = CGEvent(keyboardEventSource: nil, virtualKey: 59, keyDown: true),
             let optionKeyDown = CGEvent(keyboardEventSource: nil, virtualKey: 58, keyDown: true),
             let commandKeyDown = CGEvent(keyboardEventSource: nil, virtualKey: 55, keyDown: true) {
            
            shiftKeyDown.flags = .maskShift
            controlKeyDown.flags = .maskControl
            optionKeyDown.flags = .maskAlternate
            commandKeyDown.flags = .maskCommand
            
            shiftKeyDown.post(tap: .cgAnnotatedSessionEventTap)
            controlKeyDown.post(tap: .cgAnnotatedSessionEventTap)
            optionKeyDown.post(tap: .cgAnnotatedSessionEventTap)
            commandKeyDown.post(tap: .cgAnnotatedSessionEventTap)
            
            print("Posted key down events for modifiers")
          }
          
          isHyperkeyActive = true
        } else if type == .keyUp {
          print("F14 key up intercepted")
          
          // Synthesize new events to release the combination of keys
          if let shiftKeyUp = CGEvent(keyboardEventSource: nil, virtualKey: 56, keyDown: false),
             let controlKeyUp = CGEvent(keyboardEventSource: nil, virtualKey: 59, keyDown: false),
             let optionKeyUp = CGEvent(keyboardEventSource: nil, virtualKey: 58, keyDown: false),
             let commandKeyUp = CGEvent(keyboardEventSource: nil, virtualKey: 55, keyDown: false) {
            
            shiftKeyUp.flags = .maskShift
            controlKeyUp.flags = .maskControl
            optionKeyUp.flags = .maskAlternate
            commandKeyUp.flags = .maskCommand
            
            shiftKeyUp.post(tap: .cgAnnotatedSessionEventTap)
            controlKeyUp.post(tap: .cgAnnotatedSessionEventTap)
            optionKeyUp.post(tap: .cgAnnotatedSessionEventTap)
            commandKeyUp.post(tap: .cgAnnotatedSessionEventTap)
            
            print("Posted key up events for modifiers")
          }
          
          isHyperkeyActive = false
        }
        
        return nil // Prevent default F14 action
      }
      
      // Handle other key events when Hyperkey is active
      if isHyperkeyActive {
        print("Hyperkey active, handling key event with modifiers")
        event.flags.insert([.maskShift, .maskControl, .maskAlternate, .maskCommand])
      }
    } else if type == .flagsChanged {
      let flags = event.flags.rawValue
      print("Flags changed: \(flags)")
    }
    
    return Unmanaged.passRetained(event)
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

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
      if keyCode == 0x69 { // F14 (adjusted to match the detected keyCode)
        print("F14 key detected")
        if type == .keyDown {
          print("F14 key down intercepted")
          
          // Mimic hyper key press sequence
          injectFlagsSequence(isKeyDown: true)
          isHyperkeyActive = true
        } else if type == .keyUp {
          print("F14 key up intercepted")
          
          // Mimic hyper key release sequence
          injectFlagsSequence(isKeyDown: false)
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
  
  func injectFlagsSequence(isKeyDown: Bool) {
    // Adjust flags to better match native Hyper key behavior
    let flagsSequence: [CGEventFlags] = isKeyDown ? [
      .maskCommand,
      .maskCommand.union(.maskControl),
      .maskCommand.union(.maskControl).union(.maskShift),
      .maskCommand.union(.maskControl).union(.maskShift).union(.maskAlternate)
    ] : [
      .maskCommand.union(.maskControl).union(.maskShift).union(.maskAlternate),
      .maskCommand.union(.maskControl).union(.maskShift),
      .maskCommand.union(.maskControl),
      .maskCommand
    ]
    
    for flags in flagsSequence {
      let eventType: CGEventType = .flagsChanged
      if let flagsChangedEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) {
        flagsChangedEvent.flags = flags
        flagsChangedEvent.type = eventType
        flagsChangedEvent.post(tap: .cgAnnotatedSessionEventTap)
        print("Injected \(eventType) with flags: \(flags.rawValue). Expected: \(flagsSequence)")
      } else {
        print("Failed to create flagsChangedEvent for flags: \(flags.rawValue)")
      }
    }
    
    // Ensure flags are fully reset
    if !isKeyDown {
      if let resetEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) {
        resetEvent.flags = []
        resetEvent.type = .flagsChanged
        resetEvent.post(tap: .cgAnnotatedSessionEventTap)
        print("Injected final flags reset event with flags: 0")
      }
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

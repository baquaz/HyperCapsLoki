//
//  MiniHyperkeyApp.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 29/12/2024.
//

import IOKit.hid
import SwiftUI
import Cocoa
import Foundation

@main
struct MiniHyperkeyApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
//  var eventTap: CFMachPort?
//  var isHyperkeyActive = false
//  var lastKeyCode: CGKeyCode? = nil
//  var lastEventType: CGEventType? = nil
//  
//  private var capsLockReady = true
//  private var capsLockTriggerTimer: Task<Void, Never>?
  private var hyperkeyManager: HyperKeyManager?
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    hyperkeyManager = HyperKeyManager(remapper: Remapper(), eventsHandler: .init())
    
    hyperkeyManager?.launch()
    
    
//    // Reset previous key mappings
//    resetHidutilMappings()
//    
//    
//    // Example Usage
//    let keyboardUsages = retrieveKeyboardUsages()
//    print("Available Keyboard Usages:")
//    for (keyName, usageID) in keyboardUsages {
//      print("\(keyName): \(String(format: "0x%02X", usageID))")
//    }
//    
//    
////    // Remap Caps Lock to F14
//    remapCapsLockToF14()
////    
////    // Set up event taps
//    setupEventTap()
  }
  
//  // Function to Retrieve All Possible HID Keyboard Usages
//  func retrieveKeyboardUsages() -> [String: Int] {
//    var keyMapping: [String: Int] = [:]
//    
//    // Create a HID Manager
//    let hidManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
//    
//    // Relax Matching Criteria
//    let matchingDict: [String: Any] = [:] // Match all devices
//    IOHIDManagerSetDeviceMatching(hidManager, matchingDict as CFDictionary)
//    
//    // Open HID Manager
//    let openResult = IOHIDManagerOpen(hidManager, IOOptionBits(kIOHIDOptionsTypeNone))
//    if openResult != kIOReturnSuccess {
//      print("Failed to open HID Manager with error: \(openResult)")
//      return keyMapping
//    }
//    
//    // Get All Matching Devices
//    guard let devices = IOHIDManagerCopyDevices(hidManager) as? Set<IOHIDDevice> else {
//      print("No HID devices found.")
//      return keyMapping
//    }
//    
//    print("Devices found: \(devices.count)")
//    for device in devices {
//      // Print Device Properties
//      if let product = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String {
//        print("Found Device: \(product)")
//      }
//      
//      // Get All Elements for the Device
//      guard let elements = IOHIDDeviceCopyMatchingElements(device, nil, IOOptionBits(kIOHIDOptionsTypeNone)) as? [IOHIDElement] else {
//        continue
//      }
//      
//      for element in elements {
//        let usagePage = IOHIDElementGetUsagePage(element)
//        let usage = IOHIDElementGetUsage(element)
//        if usagePage == kHIDPage_KeyboardOrKeypad {
//          keyMapping["Usage \(usage)"] = Int(usage)
//          print("Keyboard Element - Usage Page: \(usagePage), Usage: \(usage)")
//        }
//      }
//    }
//    
//    return keyMapping
//  }

  
//  // Function to Get Symbolic Name for a Usage ID
//  func getSymbolicNameForUsage(_ usage: Int) -> String? {
//    // Map usage IDs to symbolic names (expandable)
//    let symbolicNames: [KeyName: Int] = [
//      .capsLock: kHIDUsage_KeyboardCapsLock
//    ]
//    return symbolicNames[usage]
//  }
  
  
//  func resetHidutilMappings() {
//    let command = "hidutil property --set '{\"UserKeyMapping\": []}'"
//    print("Executing command to reset key mappings: \(command)")
//    
//    let output = self.shell(command)
//    print("Command output: \(output)")
//    print("Key mappings have been reset.")
//  }
//  
//  func remapCapsLockToF14() {
//    let capsLockUsage = makeHIDUsage(page: kHIDPage_KeyboardOrKeypad, usage: kHIDUsage_KeyboardCapsLock)
//    let f14Usage = makeHIDUsage(page: kHIDPage_KeyboardOrKeypad, usage: kHIDUsage_KeyboardF14)
//    
//    let userKeyMapping: [[String: Any]] = [
//      ["HIDKeyboardModifierMappingSrc": capsLockUsage /*0x700000039*/, // Caps Lock
//       "HIDKeyboardModifierMappingDst": f14Usage /*0x700000068*/] // F14
//    ]
//    
//    do {
//      let data = try JSONSerialization.data(withJSONObject: userKeyMapping, options: [])
//      if let jsonString = String(data: data, encoding: .utf8) {
//        let command = "hidutil property --set '{\"UserKeyMapping\": \(jsonString)}'"
//        print("Executing command: \(command)")
//        let output = self.shell(command)
//        print("Command output: \(output)")
//        print("Caps Lock remapped to F14.")
//      }
//    } catch {
//      print("Error serializing JSON: \(error)")
//    }
//  }
  
  
//  /// Combines HID _Usage Page_ with _Usage ID_ into single integer
//  ///
//  /// example:
//  /// ```
//  /// 0x7  (usage page)
//  ///   | 0000000
//  ///   | 39 (usage ID)
//  /// ```
//  /// Which is `0x07` in the upper nibble of the usage field and `0x39` in the lower nibble—forming the combined 64-bit usage number.
//  ///
//  /// - Parameters:
//  ///   - page: Usage Page - tells the system which category of HID usages you're referencing
//  ///   (e.g. keyboard usages have page `0x07`).
//  ///   - usage: Usage ID - identifies the specific key within that usage page (e.g. Caps Lock is `0x39`).
//  /// - Returns: full **Usage** value
//  func makeHIDUsage(page: Int, usage: Int) -> Int {
//    (page << 32) | usage
//  }
  
//  func setupEventTap() {
//    let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
//    eventTap = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: CGEventMask(eventMask), callback: eventTapCallback, userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
//    
//    if let eventTap = eventTap {
//      let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
//      CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
//      CGEvent.tapEnable(tap: eventTap, enable: true)
//      print("Event tap set up successfully")
//    } else {
//      print("Failed to create event tap")
//    }
//  }
//  
//  let eventTapCallback: CGEventTapCallBack = { (proxy, type, event, refcon) in
//    let appDelegate = Unmanaged<AppDelegate>.fromOpaque(refcon!).takeUnretainedValue()
//    return appDelegate.handleEventTap(proxy: proxy, type: type, event: event)
//  }
//  
//  func handleEventTap(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
//    if type == .keyDown || type == .keyUp {
//      let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode)) // Convert keyCode to correct type
//      let flags = event.flags.rawValue
//      
//      // Avoid multiple handling of the same hyper key event
//      if let lastKeyCode = lastKeyCode, lastKeyCode == keyCode && lastEventType == type && keyCode == kHIDUsage_KeyboardF14 {
//        return nil
//      }
//      
//      print("Key code: \(keyCode), Flags: \(flags), Type: \(type == .keyDown ? "KeyDown" : "KeyUp")")
//      
//      let f14Usage = makeHIDUsage(page: kHIDPage_KeyboardOrKeypad, usage: kVK_F14)
//      // Handle F14 key press (remapped from Caps Lock)
//      if keyCode == CGKeyCode(f14Usage & 0xFFFF)/*kHIDUsage_KeyboardF14*/ {
//        Task {
//          await handleHyperKeyPress(type)
//        }
//        lastKeyCode = keyCode
//        lastEventType = type
//        
//        return nil // Prevent default F14 action
//        
//      } else if type == .keyDown {
//        // Cancel the timer if any other key is pressed
//        cancelCapsLockTriggerTimer()
//      }
//      
//      // Handle other key events when Hyperkey is active
//      if isHyperkeyActive {
//        print("Hyperkey active, handling key event with modifiers")
//        event.flags.insert([.maskShift, .maskControl, .maskAlternate, .maskCommand])
//      }
//      
//    } else if type == .flagsChanged {
//      let flags = event.flags.rawValue
//      print("Flags changed: \(flags)")
//    }
//    
//    return Unmanaged.passRetained(event)
//  }
//  
//  private func handleHyperKeyPress(_ type: CGEventType) async {
//    if type == .keyDown {
//      print("F14 key DOWN intercepted")
//      
//      startCapsLockTriggerTimer()
//      
//      if !isHyperkeyActive {
//        injectFlagsSequence(isKeyDown: true)
//        isHyperkeyActive = true
//      }
//      
//    } else if type == .keyUp {
//      print("F14 key UP intercepted")
//      
//      if capsLockReady {
//        print("Caps lock ready - injecting caps lock")
//        injectCapsLockFlag()
//      } else {
//        print("Caps lock unavailable")
//      }
//      
//      isHyperkeyActive = false
//      injectFlagsSequence(isKeyDown: false)
//    }
//  }
//  
//  func startCapsLockTriggerTimer() {
//    cancelCapsLockTriggerTimer()
//    capsLockReady = true
//    capsLockTriggerTimer = Task {
//      do {
//        try await Task.sleep(for: .seconds(1.5))
//        capsLockReady = false
//        print("Caps lock trigger timer expired")
//      } catch {
//        print("Caps lock trigger timer canceled")
//      }
//    }
//  }
//  
//  func cancelCapsLockTriggerTimer() {
//    capsLockTriggerTimer?.cancel()
//    capsLockTriggerTimer = nil
//    capsLockReady = false
//  }
//  
//  //Should mimic - Flags changed: 65792
//  func injectCapsLockFlag() {
//    var ioConnect: io_connect_t = 0
//    let ioService = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(kIOHIDSystemClass))
//    
//    if ioService == 0 {
//      print("Failed to find IOHID system service.")
//      return
//    }
//    
//    let result = IOServiceOpen(ioService, mach_task_self_, UInt32(kIOHIDParamConnectType), &ioConnect)
//    
//    if result != KERN_SUCCESS {
//      print("Failed to open IOService: \(result)")
//      return
//    }
//    
//    var modifierLockState: Bool = false
//    
//    // Retrieve the current state of Caps Lock
//    let getResult = IOHIDGetModifierLockState(ioConnect, Int32(kIOHIDCapsLockState), &modifierLockState)
//    
//    if getResult != KERN_SUCCESS {
//      print("Failed to get Caps Lock state: \(getResult)")
//      IOServiceClose(ioConnect)
//      return
//    }
//    
//    // Toggle the Caps Lock state
//    modifierLockState.toggle()
//    
//    // Set the new state of Caps Lock
//    let setResult = IOHIDSetModifierLockState(ioConnect, Int32(kIOHIDCapsLockState), modifierLockState)
//    
//    if setResult != KERN_SUCCESS {
//      print("Failed to set Caps Lock state: \(setResult)")
//    } else {
//      print("Caps Lock state toggled successfully.")
//    }
//    
//    IOServiceClose(ioConnect)
//  }
//
//  func injectFlagsSequence(isKeyDown: Bool) {
//    let command: CGEventFlags = .maskCommand
//    let option: CGEventFlags = .maskAlternate
//    let control: CGEventFlags = .maskControl
//    let shift: CGEventFlags = .maskShift
//    
//    let downFlagsSequence: [CGEventFlags] = [
//      command,
//      command.union(option),
//      command.union(option).union(control),
//      command.union(option).union(control).union(shift)
//    ]
//    
//    let upFlagsSequence: [CGEventFlags] = [
//      command.union(option).union(control).union(shift),
//      command.union(option).union(control),
//      command.union(option),
//      command,
//      []
//    ]
//    
//    let flagsSequence = isKeyDown ? downFlagsSequence : upFlagsSequence
//    
//    for flags in flagsSequence {
//      let eventType: CGEventType = .flagsChanged
//      if let flagsChangedEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) {
//        flagsChangedEvent.flags = flags
//        flagsChangedEvent.type = eventType
//        flagsChangedEvent.post(tap: .cghidEventTap)
//        print("Injected \(eventType) with flags: \(flags.rawValue).")
//        
//        // Introduce a small delay for processing
//        usleep(5000) // 5 milliseconds
//      } else {
//        print("Failed to create flagsChangedEvent for flags: \(flags.rawValue)")
//      }
//    }
//    
//    // Ensure flags are fully reset
//    if !isKeyDown {
//      if let resetEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) {
//        resetEvent.flags = []
//        resetEvent.type = .flagsChanged
//        resetEvent.post(tap: .cghidEventTap)
//        print("Injected final flags reset event with flags: 0")
//      }
//    }
//  }
//  
//  func shell(_ command: String) -> String {
//    let task = Process()
//    
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

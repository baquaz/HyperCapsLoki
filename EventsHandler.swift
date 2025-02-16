//
//  EventsHandler.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 26/01/2025.
//

import Foundation
import Cocoa
import IOKit.hid

@MainActor
class EventsHandler {
  let keysProvider: KeysProvider
  
  private var eventTap: CFMachPort?
  private var isHyperkeyActive = false
  private var lastKeyCode: CGKeyCode? = nil
  private var lastEventType: CGEventType? = nil
  
  private var capsLockReady = true
  private var capsLockTriggerTimer: Task<Void, Never>?
  
  private let eventTapCallback: CGEventTapCallBack = { (proxy, type, event, refcon) in
    let handler = Unmanaged<EventsHandler>.fromOpaque(refcon!).takeUnretainedValue()
    return handler.handleEventTap(proxy: proxy, type: type, event: event)
  }
  
  // MARK: - Init
  init(keysProvider: KeysProvider = .shared) {
    self.keysProvider = keysProvider
  }
  
  func setupEventTap() {
    let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
    eventTap = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: CGEventMask(eventMask), callback: eventTapCallback, userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    
    if let eventTap = eventTap {
      let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
      CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
      CGEvent.tapEnable(tap: eventTap, enable: true)
      print("Event tap set up successfully")
    } else {
      print("Failed to create event tap")
    }
  }
  
  func handleEventTap(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
    if type == .keyDown || type == .keyUp {
      let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode)) // Convert keyCode to correct type
      let flags = event.flags.rawValue
      
      // Avoid multiple handling of the same hyper key event
      if let lastKeyCode = lastKeyCode, lastKeyCode == keyCode && lastEventType == type && keyCode == kHIDUsage_KeyboardF14 {
        return nil
      }
      
      print("Key code: \(keyCode), Flags: \(flags), Type: \(type == .keyDown ? "KeyDown" : "KeyUp")")
      
      let f14Usage = keysProvider.makeHIDUsageNumber(page: kHIDPage_KeyboardOrKeypad, usage: kHIDUsage_KeyboardF14)
      // Handle F14 key press (remapped from Caps Lock)
      if keyCode == CGKeyCode(f14Usage & 0xFFFF)/*kHIDUsage_KeyboardF14*/ {
        Task {
          await handleHyperKeyPress(type)
        }
        lastKeyCode = keyCode
        lastEventType = type
        
        return nil // Prevent default F14 action
        
      } else if type == .keyDown {
        // Cancel the timer if any other key is pressed
        cancelCapsLockTriggerTimer()
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
  
  private func handleHyperKeyPress(_ type: CGEventType) async {
    if type == .keyDown {
      print("F14 key DOWN intercepted")
      
      startCapsLockTriggerTimer()
      
      if !isHyperkeyActive {
        injectHyperkeyFlagsSequence(isKeyDown: true)
        isHyperkeyActive = true
      }
      
    } else if type == .keyUp {
      print("F14 key UP intercepted")
      
      if capsLockReady {
        print("Caps lock ready - injecting caps lock")
        injectCapsLockFlag()
      } else {
        print("Caps lock unavailable")
      }
      
      isHyperkeyActive = false
      injectHyperkeyFlagsSequence(isKeyDown: false)
    }
  }
  
  func startCapsLockTriggerTimer() {
    cancelCapsLockTriggerTimer()
    capsLockReady = true
    capsLockTriggerTimer = Task {
      do {
        try await Task.sleep(for: .seconds(1.5))
        capsLockReady = false
        print("Caps lock trigger timer expired")
      } catch {
        print("Caps lock trigger timer canceled")
      }
    }
  }
  
  func cancelCapsLockTriggerTimer() {
    capsLockTriggerTimer?.cancel()
    capsLockTriggerTimer = nil
    capsLockReady = false
  }
  
  //Should mimic - Flags changed: 65792
  func injectCapsLockFlag() {
    var ioConnect: io_connect_t = 0
    let ioService = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(kIOHIDSystemClass))
    
    if ioService == 0 {
      print("Failed to find IOHID system service.")
      return
    }
    
    let result = IOServiceOpen(ioService, mach_task_self_, UInt32(kIOHIDParamConnectType), &ioConnect)
    
    if result != KERN_SUCCESS {
      print("Failed to open IOService: \(result)")
      return
    }
    
    var modifierLockState: Bool = false
    
    // Retrieve the current state of Caps Lock
    let getResult = IOHIDGetModifierLockState(ioConnect, Int32(kIOHIDCapsLockState), &modifierLockState)
    
    if getResult != KERN_SUCCESS {
      print("Failed to get Caps Lock state: \(getResult)")
      IOServiceClose(ioConnect)
      return
    }
    
    // Toggle the Caps Lock state
    modifierLockState.toggle()
    
    // Set the new state of Caps Lock
    let setResult = IOHIDSetModifierLockState(ioConnect, Int32(kIOHIDCapsLockState), modifierLockState)
    
    if setResult != KERN_SUCCESS {
      print("Failed to set Caps Lock state: \(setResult)")
    } else {
      print("Caps Lock state toggled successfully.")
    }
    
    IOServiceClose(ioConnect)
  }
  
  func injectHyperkeyFlagsSequence(isKeyDown: Bool) {
    let command: CGEventFlags = .maskCommand
    let option: CGEventFlags = .maskAlternate
    let control: CGEventFlags = .maskControl
    let shift: CGEventFlags = .maskShift
    
    let downFlagsSequence: [CGEventFlags] = [
      command,
      command.union(option),
      command.union(option).union(control),
      command.union(option).union(control).union(shift)
    ]
    
    let upFlagsSequence: [CGEventFlags] = [
      command.union(option).union(control).union(shift),
      command.union(option).union(control),
      command.union(option),
      command,
      []
    ]
    
    let flagsSequence = isKeyDown ? downFlagsSequence : upFlagsSequence
    
    for flags in flagsSequence {
      let eventType: CGEventType = .flagsChanged
      if let flagsChangedEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) {
        flagsChangedEvent.flags = flags
        flagsChangedEvent.type = eventType
        flagsChangedEvent.post(tap: .cghidEventTap)
        print("Injected \(eventType) with flags: \(flags.rawValue).")
        
        // Introduce a small delay for processing
        usleep(5000) // 5 milliseconds
      } else {
        print("Failed to create flagsChangedEvent for flags: \(flags.rawValue)")
      }
    }
    
    // Ensure flags are fully reset
    if !isKeyDown {
      if let resetEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) {
        resetEvent.flags = []
        resetEvent.type = .flagsChanged
        resetEvent.post(tap: .cghidEventTap)
        print("Injected final flags reset event with flags: 0")
      }
    }
  }
}

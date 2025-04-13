//
//  EventsHandler.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 26/01/2025.
//

import Foundation
import Cocoa
import IOKit.hid

@MainActor
final class EventsHandler {
  private var hyperKey: Key?
  
  private var hyperkeyDownSequence: [CGEventFlags] = []
  private var hyperkeyUpSequence: [CGEventFlags] = []
  
  private var eventTap: CFMachPort?
  private var isHyperkeyActive = false
  private var lastKeyCode: CGKeyCode? = nil
  private var lastEventType: CGEventType? = nil
  
  private var capsLockReady = true
  private var capsLockTriggerTimer: Task<Void, Never>?
  
  private let eventTapCallback: CGEventTapCallBack = {
    (proxy, type, event, refcon) in
    let handler = Unmanaged<EventsHandler>
      .fromOpaque(refcon!)
      .takeUnretainedValue()
    return handler.handleEventTap(proxy: proxy, type: type, event: event)
  }
  
  // MARK: - Event Tap
  /// Sets up event tap handler to detect key events and flags
  func setupEventTap() {
    let eventMask =
    (1 << CGEventType.keyDown.rawValue) |
    (1 << CGEventType.keyUp.rawValue) |
    (1 << CGEventType.flagsChanged.rawValue)
    
    eventTap = CGEvent.tapCreate(
      tap: .cghidEventTap,
      place: .headInsertEventTap,
      options: .defaultTap,
      eventsOfInterest: CGEventMask(eventMask),
      callback: eventTapCallback,
      userInfo: UnsafeMutableRawPointer(
        Unmanaged.passUnretained(self).toOpaque()
      )
    )
    
    if let eventTap {
      let runLoopSource = CFMachPortCreateRunLoopSource(
        kCFAllocatorDefault, eventTap, 0
      )
      CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
      CGEvent.tapEnable(tap: eventTap, enable: true)
      print("Event tap set up successfully")
    } else {
      print("Failed to create event tap")
    }
  }
  
  func setEventTap(enabled: Bool) {
    if let eventTap {
      CGEvent.tapEnable(tap: eventTap, enable: enabled)
    }
  }
  
  // MARK: - Configure
  func set(_ hyperKey: Key?) {
    self.hyperKey = hyperKey
  }
  
  func set(availableSequenceKeys: [Key]) {
    let availableFlags: [CGEventFlags] = availableSequenceKeys
      .compactMap({
        switch $0 {
          case .leftCommand: .maskCommand
          case .leftOption: .maskAlternate
          case .leftShift: .maskShift
          case .leftControl: .maskControl
          default: nil
        }
      })
    
    let command: CGEventFlags =
    availableFlags.contains(.maskCommand) ? .maskCommand : []
    
    let option: CGEventFlags =
    availableFlags.contains(.maskAlternate) ? .maskAlternate : []
    
    let control: CGEventFlags =
    availableFlags.contains(.maskControl) ? .maskControl : []

    let shift: CGEventFlags =
    availableFlags.contains(.maskShift) ? .maskShift : []
    
    let meta = command
    let superKey = meta.union(option)
    let hyper = superKey.union(control)
    let shifty = hyper.union(shift)
    
    let keyDownSequence: [CGEventFlags] = [
      meta,
      superKey,
      hyper,
      shifty
    ]
    
    let keyUpSequence: [CGEventFlags] = [
      shifty,
      hyper,
      superKey,
      meta,
      []
    ]
    
    hyperkeyDownSequence = deduplicated(keyDownSequence)
    hyperkeyUpSequence = deduplicated(keyUpSequence)
  }
  
  private func deduplicated(_ flags: [CGEventFlags]) -> [CGEventFlags] {
    flags.reduce(into: []) { result, flagsStep in
      if !result.contains(flagsStep) {
        result.append(flagsStep)
      }
    }
  }
  
  // MARK: - Event Tap Handler
  private func handleEventTap(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent
  ) -> Unmanaged<CGEvent>? {
    if type == .keyDown || type == .keyUp {
      let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
      let flags = event.flags.rawValue
      let hyperKeyCode = hyperKey?.carbonKeyCode
      
      // Avoid multiple handling of the same hyper key event
      if let lastKeyCode = lastKeyCode,
         lastKeyCode == keyCode &&
          lastEventType == type &&
          keyCode == hyperKeyCode {
        return nil
      }
      
      print("Key code: \(keyCode), Flags: \(flags), Type: \(type == .keyDown ? "KeyDown" : "KeyUp")")
      
      print(
      """
      🔍 Debug:
      - EventTap CGKeyCode: \(keyCode)
      - Expected Hyper CGKeyCode (\(hyperKey?.rawValue ?? "")): \(hyperKeyCode as Any)

      """
      )
      
      if keyCode == hyperKeyCode {
        Task {
          await handleHyperkeyPress(type)
        }
        lastKeyCode = keyCode
        lastEventType = type
        
        return nil // Prevent default Hyperkey source action
        
      } else if type == .keyDown {
        // Cancel the timer if any other key is pressed
        cancelCapsLockTriggerTimer()
      }
      
      // Handle other key events when Hyperkey is active
      if isHyperkeyActive {
        print("Hyper key active, handling key event with modifiers")
        event.flags.insert([.maskShift, .maskControl, .maskAlternate, .maskCommand])
      }
      
    } else if type == .flagsChanged {
      let flags = event.flags.rawValue
      print("Flags changed: \(flags)")
    }
    
    return Unmanaged.passRetained(event)
  }
  
  private func handleHyperkeyPress(_ type: CGEventType) async {
    if type == .keyDown {
      print("Hyper key DOWN intercepted")
      
      startCapsLockTriggerTimer()
      
      if !isHyperkeyActive {
        injectHyperkeyFlagsSequence(isKeyDown: true)
        isHyperkeyActive = true
      }
      
    } else if type == .keyUp {
      print("Hyper key UP intercepted")
      
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
  
  // MARK: - Caps Lock Trigger Timer
  private func startCapsLockTriggerTimer() {
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
  
  private func cancelCapsLockTriggerTimer() {
    capsLockTriggerTimer?.cancel()
    capsLockTriggerTimer = nil
    capsLockReady = false
  }
  
  // MARK: - Trigger Caps Lock
  //Should mimic - Flags changed: 65792
  private func injectCapsLockFlag() {
    var ioConnect: io_connect_t = 0
    let ioService = IOServiceGetMatchingService(
      kIOMainPortDefault,
      IOServiceMatching(
        kIOHIDSystemClass
      )
    )
    
    if ioService == 0 {
      print("Failed to find IOHID system service.")
      return
    }
    
    let result = IOServiceOpen(
      ioService, mach_task_self_, UInt32(kIOHIDParamConnectType), &ioConnect)
    
    if result != KERN_SUCCESS {
      print("Failed to open IOService: \(result)")
      return
    }
    
    var modifierLockState: Bool = false
    
    // Retrieve the current state of Caps Lock
    let getResult = IOHIDGetModifierLockState(
      ioConnect, Int32(kIOHIDCapsLockState), &modifierLockState)
    
    if getResult != KERN_SUCCESS {
      print("Failed to get Caps Lock state: \(getResult)")
      IOServiceClose(ioConnect)
      return
    }
    
    // Toggle the Caps Lock state
    modifierLockState.toggle()
    
    // Set the new state of Caps Lock
    let setResult = IOHIDSetModifierLockState(
      ioConnect, Int32(kIOHIDCapsLockState), modifierLockState)
    
    if setResult != KERN_SUCCESS {
      print("Failed to set Caps Lock state: \(setResult)")
    } else {
      print("Caps Lock state toggled successfully.")
    }
    
    IOServiceClose(ioConnect)
  }
  
  // MARK: - Trigger Hyperkey
  private func injectHyperkeyFlagsSequence(isKeyDown: Bool) {
    let flagsSequence = isKeyDown ? hyperkeyDownSequence : hyperkeyUpSequence
    
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

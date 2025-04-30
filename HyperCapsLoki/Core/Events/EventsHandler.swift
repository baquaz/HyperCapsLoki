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
class EventsHandler {
  private var systemEventsInjector: SystemEventsInjection
  private let capsLockTriggerTimer: AsyncTimer
  internal var capsLockReady = true
  
  private var hyperkey: Key?
  internal var isHyperkeyActive = false
  internal var availableEventFlags: CGEventFlags = []
  
  private var eventTap: CFMachPort?
  private var lastKeyCode: CGKeyCode? = nil
  private var lastEventType: CGEventType? = nil
  
  private let eventTapCallback: CGEventTapCallBack = {
    (proxy, type, event, refcon) in
    let handler = Unmanaged<EventsHandler>
      .fromOpaque(refcon!)
      .takeUnretainedValue()
    return handler.handleEventTap(proxy: proxy, type: type, event: event)
  }
  
  // MARK: - Init
  init(
    systemEventsInjector: SystemEventsInjection,
    capsLockTriggerTimer: AsyncTimer
  ) {
    self.systemEventsInjector = systemEventsInjector
    self.capsLockTriggerTimer = capsLockTriggerTimer
  }
  
  // MARK: - Setup Event Tap
  /// Sets up event tap handler to detect key events and flags
  func setUpEventTap() {
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
  
  // MARK: - Configure
  func setEventTap(enabled: Bool) {
    if let eventTap {
      CGEvent.tapEnable(tap: eventTap, enable: enabled)
    }
  }
  
  func set(_ hyperkey: Key?) {
    self.hyperkey = hyperkey
  }
  
  func set(availableSequenceKeys: [Key]) {
    availableEventFlags = availableSequenceKeys
      .reduce(into: []) { result, key in
        guard Key.allHyperkeySequenceKeys.contains(key) else { return }
        switch key {
          case .leftCommand:  result.insert(.maskCommand)
          case .leftOption:   result.insert(.maskAlternate)
          case .leftShift:    result.insert(.maskShift)
          case .leftControl:  result.insert(.maskControl)
          default: break
        }
      }
    
    let command: CGEventFlags =
    availableEventFlags.contains(.maskCommand) ? .maskCommand : []
    
    let option: CGEventFlags =
    availableEventFlags.contains(.maskAlternate) ? .maskAlternate : []
    
    let control: CGEventFlags =
    availableEventFlags.contains(.maskControl) ? .maskControl : []
    
    let shift: CGEventFlags =
    availableEventFlags.contains(.maskShift) ? .maskShift : []
    
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
    
    systemEventsInjector.setUpHyperkeySequenceKeyUp(keyUpSequence)
    systemEventsInjector.setUpHyperkeySequenceKeyDown(keyDownSequence)
  }
  
  // MARK: - Event Tap Handler
  internal func handleEventTap(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent
  ) -> Unmanaged<CGEvent>? {
    if type == .keyDown || type == .keyUp {
      let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
      let flags = event.flags.rawValue
      let hyperKeyCode = hyperkey?.carbonKeyCode
      
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
      - Expected Hyper CGKeyCode (\(hyperkey?.rawValue ?? "")): \(hyperKeyCode as Any)

      """
      )
      
      if keyCode == hyperKeyCode {
        
        handleHyperkeyPress(type)
        
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
        event.flags.insert(availableEventFlags)
      }
      
    } else if type == .flagsChanged {
      let flags = event.flags.rawValue
      print("Flags changed: \(flags)")
    }
    
    return Unmanaged.passRetained(event)
  }
  
  internal func handleHyperkeyPress(_ type: CGEventType) {
    switch type {
      case .keyDown:
        handleKeyDown()
      case .keyUp:
        handleKeyUp()
      case .flagsChanged:
        fallthrough
      default:
        break
    }
  }
  
  private func handleKeyDown() {
    print("Hyper key DOWN intercepted")
    startCapsLockTriggerTimer()
    
    if !isHyperkeyActive {
      systemEventsInjector.injectHyperkeyFlagsSequence(isKeyDown: true)
      isHyperkeyActive = true
    }
  }
  
  private func handleKeyUp() {
    print("Hyper key UP intercepted")
    
    if capsLockReady {
      print("Caps lock ready - injecting caps lock")
      systemEventsInjector.injectCapsLockStateToggle()
    } else {
      print("Caps lock unavailable")
    }
    
    isHyperkeyActive = false
    systemEventsInjector.injectHyperkeyFlagsSequence(isKeyDown: false)
  }
  
  // MARK: - Caps Lock Trigger Timer
  private func startCapsLockTriggerTimer() {
    cancelCapsLockTriggerTimer()
    
    capsLockReady = true
    capsLockTriggerTimer.start(interval: .seconds(1.5), repeating: false, action: { [weak self] in
      self?.capsLockReady = false
    })
  }

  private func cancelCapsLockTriggerTimer() {
    capsLockTriggerTimer.cancel()
    capsLockReady = false
  }
}

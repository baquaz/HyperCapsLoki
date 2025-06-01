//
//  EventsHandler.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 26/01/2025.
//

import Foundation
import Cocoa
import IOKit.hid

/// Handles global keyboard events, including Hyperkey detection and Caps Lock simulation.
@MainActor
open class EventsHandler {
  private var systemEventsInjector: SystemEventsInjection
  private let capsLockTriggerTimer: AsyncTimer
  internal var capsLockReady = true

  private var hyperkey: Key?
  internal var isHyperkeyActive = false
  internal var availableEventFlags: CGEventFlags = []

  private var eventTap: CFMachPort?
  private var lastKeyCode: CGKeyCode?
  private var lastEventType: CGEventType?

  /// Callback for handling tapped keyboard events.
  private let eventTapCallback: CGEventTapCallBack =
  { (proxy, type, event, refcon) in
    let handler = Unmanaged<EventsHandler>
      .fromOpaque(refcon!)
      .takeUnretainedValue()
    return handler.handleEventTap(proxy: proxy, type: type, event: event)
  }

  // MARK: - Init
  public init(
    systemEventsInjector: SystemEventsInjection,
    capsLockTriggerTimer: AsyncTimer
  ) {
    self.systemEventsInjector = systemEventsInjector
    self.capsLockTriggerTimer = capsLockTriggerTimer
  }

  // MARK: - Setup Event Tap

  /// Sets up the macOS event tap to listen for key and modifier events.
  open func setUpEventTap() {
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

      Applog.print(context: .keyboardEvents,
                   "Event tap set up successfully")
    } else {
      Applog.print(
        tag: .warning, context: .keyboardEvents, "Failed to create event tap"
      )
    }
  }

  // MARK: - Configure

  /// Enables or disables the event tap.
  open func setEventTap(enabled: Bool) {
    if let eventTap {
      CGEvent.tapEnable(tap: eventTap, enable: enabled)
      Applog.print(context: .keyboardEvents,
                   "Keyboard events handler:",
                   enabled ? "ENABLED ✅" : "DISABLED ❌")
    } else {
      Applog.print(context: .keyboardEvents,
                   "Keyboard events handler not set up yet.")
    }
  }

  /// Sets the Hyperkey to listen for.
  open func set(_ hyperkey: Key?) {
    self.hyperkey = hyperkey
  }

  /// Sets the available modifier key combinations for Hyperkey sequence handling.
  open func set(availableSequenceKeys: [Key]) {
    availableEventFlags =
    availableSequenceKeys
      .compactMap { key in
        Key.allHyperkeySequenceEventFlags[key]
      }
    // Combine all event flags into a single CGEventFlags OptionSet
      .reduce([]) { combinedFlags, currentFlags in
        combinedFlags.union(currentFlags)
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

  /// Main handler for key and modifier events intercepted by the event tap.
  ///
  /// - Parameters:
  ///   - proxy: The event tap proxy, used to post new events into the event stream.
  ///   - type: The tyoe of the incoming event (e.g., keyDown, keyUp, flags changed).
  ///   - event: The actual keyboard event being processed.
  ///
  /// - Returns: The (possibly modified) event to continue through the system, or `nil` to suppress it.
  open  func handleEventTap(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent
  ) -> Unmanaged<CGEvent>? {
    if type == .keyDown || type == .keyUp {
      let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
      let hyperKeyCode = hyperkey?.carbonKeyCode

      // Avoid multiple handling of the same hyper key event
      if let lastKeyCode = lastKeyCode,
         lastKeyCode == keyCode &&
          lastEventType == type &&
          keyCode == hyperKeyCode {
        return nil
      }

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
        event.flags.insert(availableEventFlags)
        Applog.print(context: .keyboardEvents,
                     "<Hyperkey> active, handling key event with modifiers")
      }
    }

    return Unmanaged.passRetained(event)
  }

  /// Delegates key event type to the corresponding Hyperkey press handler.
  open func handleHyperkeyPress(_ type: CGEventType) {
    switch type {
      case .keyDown:
        handleKeyDown()
      case .keyUp:
        handleKeyUp()
      default:
        break
    }
  }

  /// Handles logic for Hyperkey pressed down.
  private func handleKeyDown() {
    Applog.print(
      context: .keyboardEvents, "<Hyperkey> DOWN intercepted")
    startCapsLockTriggerTimer()

    if !isHyperkeyActive {
      systemEventsInjector.injectHyperkeyFlagsSequence(isKeyDown: true)
      isHyperkeyActive = true
    }
  }

  /// Handles logic for Hyperkey released.
  private func handleKeyUp() {
    Applog.print(context: .keyboardEvents,
                 "<Hyperkey> UP intercepted")
    if capsLockReady {
      Applog.print(context: .keyboardEvents,
                   "Toggle Caps Lock action")
      systemEventsInjector.injectCapsLockStateToggle()
    } else {
      Applog.print(context: .keyboardEvents,
                   "Caps lock unavailable")
    }

    isHyperkeyActive = false
    systemEventsInjector.injectHyperkeyFlagsSequence(isKeyDown: false)
  }

  // MARK: - Caps Lock Trigger Timer

  /// Starts a short timer to allow Caps Lock to be triggered by Hyperkey release.
  private func startCapsLockTriggerTimer() {
    cancelCapsLockTriggerTimer()

    capsLockReady = true
    capsLockTriggerTimer.start(interval: .seconds(1.5), repeating: false) { [weak self] in
      self?.capsLockReady = false
    }
  }

  /// Cancels the Caps Lock trigger timer.
  private func cancelCapsLockTriggerTimer() {
    capsLockTriggerTimer.cancel()
    capsLockReady = false
  }
}

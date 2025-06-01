//
//  SystemEventsInjector.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 19/04/2025.
//

import Foundation
import Cocoa
import IOKit.hid

// MARK: - SystemEventsInjection

/// Protocol defining the behavior for injecting system-level keyboard events.
public protocol SystemEventsInjection {

  /// Sequence of modifier flags to be injected on hyperkey down.
  var hyperkeyDownSequence: [CGEventFlags] { get set }
  /// Sequence of modifier flags to be injected on hyperkey up.
  var hyperkeyUpSequence: [CGEventFlags] { get set }

  /// Sets the modifier flag sequence for hyperkey down.
  mutating func setUpHyperkeySequenceKeyDown(_ sequence: [CGEventFlags])

  /// Sets the modifier flag sequence for hyperkey up.
  mutating func setUpHyperkeySequenceKeyUp(_ sequence: [CGEventFlags])

  /// Injects a sequence of modifier flags simulating hyperkey press or release.
  func injectHyperkeyFlagsSequence(isKeyDown: Bool)

  /// Toggles the current state of Caps Lock at the system level.
  func injectCapsLockStateToggle()
}

public extension SystemEventsInjection {
  // MARK: - Set Hyperkey Available Sequence Keys
  mutating func setUpHyperkeySequenceKeyDown(_ sequence: [CGEventFlags]) {
    hyperkeyDownSequence = deduplicated(sequence)
  }

  mutating func setUpHyperkeySequenceKeyUp(_ sequence: [CGEventFlags]) {
    hyperkeyUpSequence = deduplicated(sequence)
  }

  private func deduplicated(_ flags: [CGEventFlags]) -> [CGEventFlags] {
    flags.reduce(into: []) { result, flagsStep in
      if !result.contains(flagsStep) {
        result.append(flagsStep)
      }
    }
  }

  // MARK: - Inject Hyperkey

  /// Posts a sequence of `.flagsChanged` events to simulate hyperkey modifier press or release.
  ///
  /// - Parameter isKeyDown: `true` for key down sequence, `false` for key up.
  func injectHyperkeyFlagsSequence(isKeyDown: Bool) {
    let flagsSequence = isKeyDown ? hyperkeyDownSequence : hyperkeyUpSequence

    for flags in flagsSequence {
      let eventType: CGEventType = .flagsChanged
      if let flagsChangedEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) {
        flagsChangedEvent.flags = flags
        flagsChangedEvent.type = eventType
        flagsChangedEvent.post(tap: .cghidEventTap)

        // Introduce a small delay for processing
        usleep(5000) // 5 milliseconds
      } else {
        Applog.print(
          tag: .critical,
          context: .keyboardEvents,
          "Failed injecting part of <Hyperkey> sequence!"
        )
      }
    }

    // Ensure all modifiers are reset after key up
    if !isKeyDown {
      if let resetEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) {
        resetEvent.flags = []
        resetEvent.type = .flagsChanged
        resetEvent.post(tap: .cghidEventTap)
        Applog.print(context: .keyboardEvents, "<Hyperkey> sequence off")
      }
    }
  }

  // MARK: - Inject Caps Lock

  /// Uses IOKit APIs to toggle the system Caps Lock key state.
  func injectCapsLockStateToggle() {
    var ioConnect: io_connect_t = 0
    let ioService = IOServiceGetMatchingService(
      kIOMainPortDefault,
      IOServiceMatching(
        kIOHIDSystemClass
      )
    )

    if ioService == 0 {
      Applog.print(
        tag: .critical,
        context: .keyboardEvents,
        "Failed to find IOHID system service."
      )
      return
    }

    let result = IOServiceOpen(
      ioService, mach_task_self_, UInt32(kIOHIDParamConnectType), &ioConnect)

    if result != KERN_SUCCESS {
      Applog.print(
        tag: .critical,
        context: .keyboardEvents,
        "Failed to open IOService: \(result)"
      )
      return
    }

    var modifierLockState: Bool = false

    // Read current state of Caps Lock
    let getResult = IOHIDGetModifierLockState(
      ioConnect, Int32(kIOHIDCapsLockState), &modifierLockState)

    if getResult != KERN_SUCCESS {
      Applog.print(
        tag: .critical,
        context: .keyboardEvents,
        "Failed to get Caps Lock state: \(getResult)"
      )
      IOServiceClose(ioConnect)
      return
    }

    // Toggle the Caps Lock state
    modifierLockState.toggle()

    // Set the new state of Caps Lock
    let setResult = IOHIDSetModifierLockState(
      ioConnect, Int32(kIOHIDCapsLockState), modifierLockState)

    if setResult != KERN_SUCCESS {
      Applog.print(
        tag: .critical,
        context: .keyboardEvents,
        "Failed to set Caps Lock state: \(setResult)"
      )
    } else {
      Applog.print(context: .keyboardEvents,
                   "Caps Lock state toggled successfully.")
    }

    IOServiceClose(ioConnect)
  }
}

// MARK: - SystemEventsInjector
struct SystemEventsInjector: SystemEventsInjection {
  var hyperkeyDownSequence: [CGEventFlags] = []
  var hyperkeyUpSequence: [CGEventFlags] = []
}

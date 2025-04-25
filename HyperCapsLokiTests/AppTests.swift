//
//  HyperCapsLokiTests.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 08/04/2025.
//

import Testing
@testable import HyperCapsLoki
import CoreGraphics

@Suite("Events Handler Tests")
struct EventsHandlerTests {
  
  @MainActor
  @Test func setupEventTap() async {
    let handler = MockEventsHandler(
      systemEventsInjector: MockSystemEventsInjector(),
      capsLockTriggerTimer: MockCapsLockTriggerTimer()
    )
    
    handler.setUpEventTap()
    
    #expect(handler.setUpEventTapCalled == true)
  }
  
  @MainActor
  @Test("Setting event tap enabled/disabled",
        arguments: [true, false])
  func settingEventTap(isEnabled: Bool) async {
    let handler = MockEventsHandler(
      systemEventsInjector: MockSystemEventsInjector(),
      capsLockTriggerTimer: MockCapsLockTriggerTimer()
    )
    
    handler.setEventTap(enabled: isEnabled)
    
    #expect(handler.receivedSetEventTapEnabled == isEnabled)
  }
  
  @MainActor
  @Test("Setting hyperkey",
        arguments: [Key.f15, nil])
  func settingHyperkey(_ key: Key?) {
    let handler = MockEventsHandler(
      systemEventsInjector: MockSystemEventsInjector(),
      capsLockTriggerTimer: MockCapsLockTriggerTimer()
    )
    
    handler.set(key)
    
    #expect(handler.receivedHyperkey == key)
  }
  
  @MainActor
  @Test(
    "Setting hyperkey available sequence keys",
    arguments: [
      Key.allHyperkeySequenceKeys,
      [.capsLock], // caps lock is not part of allHyperkeySequenceKeys
      [.capsLock, .leftCommand],
      []
    ])
  func settingHyperkeyAvailableSequenceKeys(_ inputKeys: [Key]) async {
    let mockInjector = MockSystemEventsInjector()
    let handler = MockEventsHandler(
      systemEventsInjector: mockInjector,
      capsLockTriggerTimer: MockCapsLockTriggerTimer()
    )
    
    handler.set(availableSequenceKeys: inputKeys)
    
    #expect(
      handler.availableEventFlags.isEmpty == inputKeys
        .filter({ Key.allHyperkeySequenceKeys.contains($0) })
        .isEmpty
    )
    mockInjector.hyperkeyUpSequence.forEach { flags in
      #expect(handler.availableEventFlags.contains(flags))
    }
    mockInjector.hyperkeyDownSequence.forEach { flags in
      #expect(handler.availableEventFlags.contains(flags))
    }
  }
  
  @MainActor
  @Test(
    "Event Tap returned value for hyperkey and other key events",
    arguments:
      [
        Key.f15, // hyperkey
        Key.f4 // other key
      ],
    [
      CGEventType.keyDown,
      CGEventType.keyUp,
      CGEventType.flagsChanged
    ])
  func handleEventTap(eventKey: Key, eventType: CGEventType) async throws {
    // Setup
    let hyperkey = Key.f15
    let isKeyDown = eventType == .keyDown
    let isKeyUpOrDown = isKeyDown || eventType == .keyUp
    
    let fakeEvent = CGEvent(
      keyboardEventSource: nil,
      virtualKey: UInt16(eventKey.carbonKeyCode),
      keyDown: isKeyDown || eventType == .flagsChanged
    )!
    let mockTimer = MockCapsLockTriggerTimer()
    let handler = MockEventsHandler(
      systemEventsInjector: MockSystemEventsInjector(),
      capsLockTriggerTimer: mockTimer
    )
    
    handler.set(hyperkey)
    
    let dummyProxy = UnsafeMutableRawPointer(bitPattern: 0x1)!
    let proxy = OpaquePointer(dummyProxy)
    
    // Act
    let returned = handler.handleEventTap(
      proxy: proxy,
      type: eventType,
      event: fakeEvent
    )
    
    // Assert
    if isKeyUpOrDown && eventKey == hyperkey {
      #expect(returned == nil)
    } else {
      #expect(returned != nil)
    }
    if isKeyDown && eventKey != hyperkey {
      #expect(mockTimer.cancelled == true)
    }
  }
  
  @MainActor
  @Test(
    "Key Down: triggers caps lock timer, activates hyperkey sequence if needed",
    arguments: [true, false]
  )
  func handleHyperkeyPressKeyDown(_ isHyperkeyActive: Bool) async throws {
    let mockTimer = MockCapsLockTriggerTimer()
    let mockInjector = MockSystemEventsInjector()
    let handler = MockEventsHandler(
      systemEventsInjector: mockInjector,
      capsLockTriggerTimer: mockTimer
    )
    handler.isHyperkeyActive = isHyperkeyActive // simulate pre-state
    
    handler.handleHyperkeyPress(.keyDown)
    
    // Timer started on keyDown
    #expect(mockTimer.started == true)
    
    if isHyperkeyActive {
      #expect(mockInjector.injectedSequence.isEmpty)
    } else {
      #expect(mockInjector.injectedSequence.first == true)
    }
    // Should activate hyperkey sequence if it was not injected yet
    #expect(handler.isHyperkeyActive == true)
  }
  
  @MainActor
  @Test(
    "Key Up: injects or skips caps lock, deactivates hyperkey sequence",
    arguments: [true, false]
  )
  func handleHyperkeyPressKeyUp(_ isCapsLockReady: Bool) async throws {
    let mockInjector = MockSystemEventsInjector()
    let handler = MockEventsHandler(
      systemEventsInjector: mockInjector,
      capsLockTriggerTimer: MockCapsLockTriggerTimer()
    )
    
    handler.capsLockReady = isCapsLockReady // simulate pre-state
    
    handler.handleHyperkeyPress(.keyUp)
    
    // Caps lock should trigger only if it was ready
    if handler.capsLockReady {
      #expect(mockInjector.capsLockToggled == true)
    } else {
      #expect(mockInjector.capsLockToggled != true)
    }
    
    // Deactivates hyperkey sequence
    #expect(handler.isHyperkeyActive == false)
    #expect(mockInjector.injectedSequence.first == false)
  }
}

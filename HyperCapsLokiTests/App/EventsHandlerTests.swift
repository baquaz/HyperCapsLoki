//
//  EventsHandlerTests.swift
//  EventsHandlerTests
//
//  Created by Piotr Błachewicz on 08/04/2025.
//

import Testing
@testable import HyperCapsLoki
import CoreGraphics

@Suite("Events Handler Tests")
struct EventsHandlerTests { }

extension EventsHandlerTests {
  struct SetupTests {
    @MainActor
    @Test func setupEventTap() async {
      let testEnv = TestEnvironment()
        .makeEventsHandler()
      
      let sut = testEnv.mockEventsHandler!
      
      sut.setUpEventTap()
      
      #expect(sut.setUpEventTapCalled == true)
    }
    
    @MainActor
    @Test("Setting event tap enabled/disabled",
          arguments: [true, false])
    func settingEventTap(isEnabled: Bool) async {
      let testEnv = TestEnvironment()
        .makeEventsHandler()
      
      let sut = testEnv.mockEventsHandler!
      
      sut.setEventTap(enabled: isEnabled)
      
      #expect(sut.receivedSetEventTapEnabled == isEnabled)
    }
    
    @MainActor
    @Test("Setting hyperkey",
          arguments: [Key.f15, nil])
    func settingHyperkey(_ key: Key?) {
      let testEnv = TestEnvironment()
        .makeEventsHandler()
      
      let sut = testEnv.mockEventsHandler!
      
      sut.set(key)
      
      #expect(sut.receivedHyperkey == key)
    }
    
    @MainActor
    @Test(
      "Setting hyperkey available sequence keys makes correct key up/down event flags",
      arguments: [
        Key.allHyperkeySequenceKeys,
        [.capsLock], // caps lock is not part of allHyperkeySequenceKeys
        [.capsLock, .leftCommand],
        []
      ])
    func settingHyperkeyAvailableSequenceKeys(_ testKeys: [Key]) async {
      let testEnv = TestEnvironment()
        .makeSystemEventsInjector()
        .makeEventsHandler()
      
      let sut = testEnv.mockEventsHandler!
      
      sut.set(availableSequenceKeys: testKeys)
      
      #expect(
        sut.availableEventFlags.isEmpty == testKeys
          .filter({ Key.allHyperkeySequenceKeys.contains($0) })
          .isEmpty
      )
      testEnv.systemEventsInjector.hyperkeyUpSequence.forEach { flags in
        #expect(sut.availableEventFlags.contains(flags))
      }
      testEnv.systemEventsInjector.hyperkeyDownSequence.forEach { flags in
        #expect(sut.availableEventFlags.contains(flags))
      }
    }
  }
}

extension EventsHandlerTests {
  struct HandlerTests {
    @MainActor
    @Test(
      "Event Tap returns nil for hyperkey on key up/down, passes other keys through",
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
      let testEnv = TestEnvironment()
        .makeCapsLockTriggerTimer()
        .makeEventsHandler()
      
      // Setup
      let hyperkey = Key.f15
      let isKeyDown = eventType == .keyDown
      let isKeyUpOrDown = isKeyDown || eventType == .keyUp
      
      let fakeEvent = CGEvent(
        keyboardEventSource: nil,
        virtualKey: UInt16(eventKey.carbonKeyCode),
        keyDown: isKeyDown || eventType == .flagsChanged
      )!
      
      let sut = testEnv.mockEventsHandler!
      sut.set(hyperkey)
      
      let dummyProxy = UnsafeMutableRawPointer(bitPattern: 0x1)!
      let proxy = OpaquePointer(dummyProxy)
      
      // Act
      let returned = sut.handleEventTap(
        proxy: proxy,
        type: eventType,
        event: fakeEvent
      )
      
      // Assert
      // Hyperkey press/release should be filtered (return nil)
      if isKeyUpOrDown && eventKey == hyperkey {
        #expect(returned == nil)
      } else {
        #expect(returned != nil)
      }
      
      // Additional keys should cancel the CapsLock delay
      if isKeyDown && eventKey != hyperkey {
        #expect(testEnv.mockCapsLockTriggerTimer.cancelled == true)
      }
    }
    
    @MainActor
    @Test("Avoids multiple handling of the same hyperkey event")
    func handleEventTapDuplicatedHyperkey() async throws {
      let testEnv = TestEnvironment()
        .makeCapsLockTriggerTimer()
        .makeEventsHandler()
      
      // Setup
      let hyperkey = Key.f18
      let fakeEvent = CGEvent(
        keyboardEventSource: nil,
        virtualKey: UInt16(hyperkey.carbonKeyCode),
        keyDown: true
      )!
      
      let sut = testEnv.mockEventsHandler!
      sut.set(hyperkey)
      
      let dummyProxy = UnsafeMutableRawPointer(bitPattern: 0x1)!
      let proxy = OpaquePointer(dummyProxy)
      
      // Act
      let returned1 = sut.handleEventTap(
        proxy: proxy,
        type: .keyDown,
        event: fakeEvent
      )
      // reset
      sut.handleHyperkeyPressCalled = false
      
      let returned2 = sut.handleEventTap(
        proxy: proxy,
        type: .keyDown,
        event: fakeEvent
      )
      
      // Assert
      #expect(returned2 == nil)
      #expect(sut.handleHyperkeyPressCalled == false)
    }
    
    @MainActor
    @Test(
      "Key Down: triggers caps lock timer, activates hyperkey sequence if needed",
      arguments: [true, false]
    )
    func handleHyperkeyPressKeyDown(_ isHyperkeyActive: Bool) async throws {
      let testEnv = TestEnvironment()
        .makeCapsLockTriggerTimer()
        .makeSystemEventsInjector()
        .makeEventsHandler()
      
      let sut = testEnv.mockEventsHandler!
      sut.isHyperkeyActive = isHyperkeyActive // simulate pre-state
      
      sut.handleHyperkeyPress(.keyDown)
      
      // Timer started on keyDown
      #expect(testEnv.mockCapsLockTriggerTimer.started == true)
      
      if isHyperkeyActive {
        #expect(testEnv.mockSystemEventsInjector.injectedSequence.isEmpty)
      } else {
        #expect(testEnv.mockSystemEventsInjector.injectedSequence.first == true)
      }
      // Should activate hyperkey sequence if it was not injected yet
      #expect(sut.isHyperkeyActive == true)
    }
    
    @MainActor
    @Test(
      "Key Up: injects or skips caps lock, deactivates hyperkey sequence",
      arguments: [true, false]
    )
    func handleHyperkeyPressKeyUp(_ isCapsLockReady: Bool) async throws {
      let testEnv = TestEnvironment()
        .makeSystemEventsInjector()
        .makeEventsHandler()
      let sut = testEnv.mockEventsHandler!
      
      sut.capsLockReady = isCapsLockReady // simulate pre-state
      
      sut.handleHyperkeyPress(.keyUp)
      
      // Caps lock should trigger only if it was ready
      if sut.capsLockReady {
        #expect(testEnv.mockSystemEventsInjector.capsLockToggled == true)
      } else {
        #expect(testEnv.mockSystemEventsInjector.capsLockToggled != true)
      }
      
      // Deactivates hyperkey sequence
      #expect(sut.isHyperkeyActive == false)
      #expect(testEnv.mockSystemEventsInjector.injectedSequence.first == false)
    }
  }
}

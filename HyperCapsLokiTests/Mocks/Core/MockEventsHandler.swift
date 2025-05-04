//
//  MockEventsHandler.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
import Cocoa
@testable import HyperCapsLoki

@MainActor
class MockEventsHandler: EventsHandler {
  
  var handleHyperkeyPressCalled = false
  private(set) var setUpEventTapCalled = false
  
  private(set) var receivedSetEventTapValue: Bool?
  private(set) var receivedHyperkey: Key?
  private(set) var receivedAvailableSequenceKeys: [Key]?
  
  
  override func setUpEventTap() {
    setUpEventTapCalled = true
  }
  
  override func setEventTap(enabled: Bool) {
    receivedSetEventTapValue = enabled
  }
  
  override func set(_ hyperkey: Key?) {
    super.set(hyperkey)
    receivedHyperkey = hyperkey
  }
  
  override func set(availableSequenceKeys: [Key]) {
    super.set(availableSequenceKeys: availableSequenceKeys)
    receivedAvailableSequenceKeys = availableSequenceKeys
  }
  
  override func handleHyperkeyPress(_ type: CGEventType) {
    super.handleHyperkeyPress(type)
    handleHyperkeyPressCalled = true
  }
}

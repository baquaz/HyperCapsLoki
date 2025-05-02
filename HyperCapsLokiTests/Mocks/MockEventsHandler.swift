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
  
  private(set) var receivedSetEventTapEnabled: Bool?
  private(set) var receivedHyperkey: Key?
  private(set) var receivedAvailableSequenceKeys: [Key]?
  
  
  override func setUpEventTap() {
    setUpEventTapCalled = true
  }
  
  override func setEventTap(enabled: Bool) {
    receivedSetEventTapEnabled = enabled
  }
  
  override func set(_ hyperkey: Key?) {
    super.set(hyperkey)
    receivedHyperkey = hyperkey
  }
  
  override func handleHyperkeyPress(_ type: CGEventType) {
    super.handleHyperkeyPress(type)
    handleHyperkeyPressCalled = true
  }
}

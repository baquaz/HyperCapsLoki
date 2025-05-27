//
//  MockSystemEventsInjector.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
import Cocoa
@testable import HyperCapsLokiModule

class MockSystemEventsInjector: SystemEventsInjection {
  var hyperkeyDownSequence: [CGEventFlags] = []
  var hyperkeyUpSequence: [CGEventFlags] = []

  var injectedSequence: [Bool] = []
  private(set) var capsLockToggled = false

  func injectHyperkeyFlagsSequence(isKeyDown: Bool) {
    injectedSequence.append(isKeyDown)
  }

  func injectCapsLockStateToggle() {
    capsLockToggled = true
  }
}

//
//  MockAsyncTimer.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
@testable import HyperCapsLoki

final class MockAsyncTimer: AsyncTimer {
  private(set) var started = false
  private(set) var cancelled = false
  private(set) var expired = false
  private var onExpire: (@MainActor () -> Void)?
  
  func start(interval: Duration,repeating: Bool,
             action: @escaping @MainActor @Sendable () -> Void
  ) {
    started = true
    self.onExpire = action
  }
  
  func cancel() {
    cancelled = true
  }
  
  func simulateExpiration() async {
    expired = true
    Task { @MainActor in
      onExpire?()
    }
  }
}

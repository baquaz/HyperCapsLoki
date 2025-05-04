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
    cancelled = false
    expired = false
    onExpire = action
  }
  
  func cancel() {
    cancelled = true
    onExpire = nil
  }
  
  func simulateExpiration() async {
    guard !cancelled, let action = onExpire else { return }
    expired = true
    Task { @MainActor in
      action()
    }
  }
}

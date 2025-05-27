//
//  AsyncAssertion.swift
//  HyperCapsLokiModule
//
//  Created by Piotr Błachewicz on 11/05/2025.
//

import Foundation

actor AsyncAssertion {
  private var wasCalled = false

  /// Call this if the event you want to monitor is triggered.
  func markCalled() {
    wasCalled = true
  }

  /// Asserts that `markCalled()` was NOT called within the given timeout.
  func assertNotCalled(timeout: TimeInterval = 1.0) async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
      // Task 1: Wait for timeout
      group.addTask {
        try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
      }

      // Task 2: Continuously check if it was called
      group.addTask {
        while true {
          try await Task.sleep(nanoseconds: 50_000_000) // 50ms poll interval
          let triggered = await self.wasCalled
          if triggered {
            throw TestError(message: "Expected no call, but markCalled() was triggered.")
          }
        }
      }

      // Wait for the timeout to finish
      try await group.next()
      group.cancelAll()
    }
  }

  struct TestError: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
  }
}

extension AsyncAssertion {
  func didNotCall(timeout: TimeInterval = 1.0) async -> Bool {
    do {
      try await assertNotCalled(timeout: timeout)
      return true
    } catch {
      return false
    }
  }
}

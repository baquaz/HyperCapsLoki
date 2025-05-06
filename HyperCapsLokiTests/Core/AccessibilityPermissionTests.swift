//
//  AccessibilityPermissionTests.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
import Testing
@testable import HyperCapsLoki

extension CoreTests {
  
  @Suite("Accessibility Permission Tests")
  struct AccessibilityPermissionTests {
    
    @MainActor
    @Test(
      "startMonitoring calls completion",
      .timeLimit(.minutes(1)) // just in case
    )
    func startMonitoringCallsCompletion() async throws {
      let timer = MockAsyncTimer()
      var isPermissionGranted = false
      var results: [Bool] = []
      
      let sut = AccessibilityPermissionHandler(
        fastInterval: .seconds(1.0),
        backoffIntervals: [
          .seconds(0),
          .seconds(1),
          .seconds(3)
        ],
        permissionCheckTimer: timer,
        permissionStatusProvider: { isPermissionGranted }
      )
      
      // Act
      sut.startMonitoring { results.append($0) }
      
      // Assert
      
      // 1st check: permission is false
      await timer.simulateExpiration()
      #expect(results == [false])
      
      // 2nd check: permission becomes true
      isPermissionGranted = true
      await timer.simulateExpiration()
      #expect(results == [false , true])
      
      // 3rd check should not be called after stopMonitoring
      sut.stopMonitoring()
      await timer.simulateExpiration()
      #expect(results == [false, true])  // unchanged
    }
    
  }
  
}

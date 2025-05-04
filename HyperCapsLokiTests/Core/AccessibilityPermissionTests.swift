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
      
      var stubbed = false
      
      let sut = AccessibilityPermissionHandler(
        fastInterval: .seconds(1.0),
        backoffIntervals: [
          .seconds(0),
          .seconds(1),
          .seconds(3)
        ],
        permissionCheckTimer: timer,
        permissionStatusProvider: { stubbed }
      )
      
      var results: [Bool] = []
      
      sut.startMonitoring { permissionGranted in
        results.append(permissionGranted)
      }
      
      await timer.simulateExpiration()
      #expect(results == [false])
      
      stubbed = true
      await timer.simulateExpiration()
      #expect(results == [false , true])
      
      // Tear down
      sut.stopMonitoring()
      
      // Simulate again — nothing should happen
      await timer.simulateExpiration()
      #expect(results == [false, true])  // no change
    }
    
  }
  
}

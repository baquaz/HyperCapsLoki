//
//  MockPermissionUseCase.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 04/05/2025.
//

import Foundation
@testable import HyperCapsLoki

final class MockPermissionUseCase: AccessibilityPermissionUseCase {
  var isGranted = false
  
  private(set) var receivedCompletion: ((Bool) -> Void)?
  
  private(set) var openAccessibilityPermissionSettingsCalled = false
  private(set) var stopMonitoringCalled = false
  
  func openAccessibilityPermissionSettings() {
    openAccessibilityPermissionSettingsCalled = true
  }
  
  func ensureAccessibilityPermissionsAreGranted() -> Bool {
    isGranted
  }
  
  func monitorChanges(completion: @escaping (Bool) -> Void) {
    receivedCompletion = completion
  }
  
  func stopMonitoring() {
    stopMonitoringCalled = true
  }
  
  
}

//
//  MockPermissionUseCase.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 04/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

final class MockPermissionUseCase: AccessibilityPermissionUseCase {
  var isGranted = false

  var receivedCompletion: ((Bool) -> Void)?
  private(set) var ensureAccessibilityPermissionsCalled = false
  private(set) var openAccessibilityPermissionSettingsCalled = false
  private(set) var stopMonitoringCalled = false

  func openAccessibilityPermissionSettings() {
    openAccessibilityPermissionSettingsCalled = true
  }

  func ensureAccessibilityPermissionsAreGranted() -> Bool {
    ensureAccessibilityPermissionsCalled = true
    return isGranted
  }

  func monitorChanges(completion: @escaping (Bool) -> Void) {
    receivedCompletion = completion
  }

  func stopMonitoring() {
    stopMonitoringCalled = true
  }

}

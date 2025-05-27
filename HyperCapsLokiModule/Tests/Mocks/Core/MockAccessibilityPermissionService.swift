//
//  MockAccessibilityPermissionService.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

class MockAccessibilityPermissionService: AccessibilityPermissionService {
  private(set) var openAccessibilitySettingsCalled = false
  
  var permissionGranted = false
  var shouldRequestAuthorizationSucceded = true
  
  // Monitoring tracking
  private(set) var startMonitoringCalled = false
  private(set) var stopMonitoringCalled = false
  var completion: ((Bool) -> Void)?
  
  func openAccessibilitySettings() {
    openAccessibilitySettingsCalled = true
  }
  
  func isPermissionGranted() -> Bool {
    permissionGranted
  }
  
  func requestAuthorizationIfNeeded() -> Bool {
    shouldRequestAuthorizationSucceded
  }
  
  func startMonitoring(completion: @escaping (Bool) -> Void) {
    startMonitoringCalled = true
    self.completion = completion
  }
  
  func stopMonitoring() {
    stopMonitoringCalled = true
    completion = nil
  }
  
  // MARK: - Manual Triggers for Tests
  func triggerPermissionChange(granted: Bool) {
    permissionGranted = granted
    completion?(granted)
  }
}

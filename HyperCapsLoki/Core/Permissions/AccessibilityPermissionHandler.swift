//
//  AccessibilityPermissionHandler.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 26/04/2025.
//

import Foundation
import ApplicationServices
import IOKit

// MARK: - Permission Monitoring
@MainActor
protocol AccessibilityPermissionMonitoring {
  func startMonitoring(completion: @escaping (_ permissionGranted: Bool) -> Void)
  func stopMonitoring()
}

// MARK: - Permission Checking
@MainActor
protocol AccessibilityPermissionChecking {
  func isPermissionGranted() -> Bool
  func requestAuthorizationIfNeeded() -> Bool
}

// MARK: - Permission Service
typealias AccessibilityPermissionService =
AccessibilityPermissionMonitoring & AccessibilityPermissionChecking

@Observable
final class AccessibilityPermissionHandler: AccessibilityPermissionService {
  internal let permissionCheckTimer: AsyncTimer = DefaultAsyncTimer()
  
  private var currentInterval: Duration
  private let fastInterval: Duration
  private let backOffIntervals: [Duration]
  private var backOffIndex = 0
  
  // MARK: - Init
  init(
    fastInterval: Duration = .seconds(3.0),
    backoffIntervals: [Duration] = [
      .seconds(0),
      .seconds(10),
      .seconds(30),
      .seconds(60),
      .seconds(120),
      .seconds(300),
    ]
  ) {
    self.fastInterval = fastInterval
    self.backOffIntervals = backoffIntervals
    self.currentInterval = fastInterval
  }
  
  // MARK: - Monitoring
  func startMonitoring(completion: @escaping (_ permissionGranted: Bool) -> Void) {
    scheduleTimer(completion: completion)
  }
  
  func stopMonitoring() {
    permissionCheckTimer.cancel()
  }
  
  private func scheduleTimer(completion: @escaping (_ permissionGranted: Bool) -> Void) {
    print("[PERM]: startMonitoring with interval: \(currentInterval)")
    permissionCheckTimer.start(interval: currentInterval, repeating: false)
    { [weak self] in
      guard let self else { return }
      print("[AccessibilityMonitor] checking permission…")
      let isGranted = isPermissionGranted()
      adjustMonitoringInterval(forPermission: isGranted)
      
      completion(isGranted)
      scheduleTimer(completion: completion)
    }
  }
  
  private func adjustMonitoringInterval(forPermission granted: Bool) {
    if granted {
      // Slow down
      if backOffIndex < backOffIntervals.count - 1 {
        backOffIndex += 1
      }
      currentInterval = backOffIntervals[backOffIndex]
    } else {
      backOffIndex = 0
      // Set fast
      currentInterval = fastInterval
    }
  }
  
  // MARK: - Checking
  func isPermissionGranted() -> Bool {
    AXIsProcessTrusted()
  }
  
  func requestAuthorizationIfNeeded() -> Bool {
    let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
    return AXIsProcessTrustedWithOptions(options)
  }
}



// Mock service for test

//struct MockAccessibilityPermissionsService: AccessibilityPermissionChecking {
//  var isAuthorizedValue: Bool
//  var requestAuthorizationResult: Bool
//  
//  func isAuthorized() async -> Bool {
//    isAuthorizedValue
//  }
//  
//  func requestAuthorizationIfNeeded() async -> Bool {
//    requestAuthorizationResult
//  }
//}

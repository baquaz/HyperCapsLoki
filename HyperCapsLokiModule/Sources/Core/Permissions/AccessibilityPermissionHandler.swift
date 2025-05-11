//
//  AccessibilityPermissionHandler.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 26/04/2025.
//

import Foundation
import ApplicationServices
import IOKit
import AppKit

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

// MARK: - Permission Settings Opener
@MainActor
protocol AccessibilityPermissionOpener {
  func openAccessibilitySettings()
}

// MARK: - Permission Service
typealias AccessibilityPermissionService =
AccessibilityPermissionMonitoring & AccessibilityPermissionChecking & AccessibilityPermissionOpener

@Observable
final class AccessibilityPermissionHandler: AccessibilityPermissionService {
  internal let permissionCheckTimer: AsyncTimer
  private let permissionStatusProvider: () -> Bool
  
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
    ],
    permissionCheckTimer: AsyncTimer = DefaultAsyncTimer(),
    permissionStatusProvider: @escaping () -> Bool = { AXIsProcessTrusted() }
  ) {
    self.fastInterval = fastInterval
    self.backOffIntervals = backoffIntervals
    self.currentInterval = fastInterval
    self.permissionCheckTimer = permissionCheckTimer
    self.permissionStatusProvider = permissionStatusProvider
  }
  
  // MARK: - Open Settings
  func openAccessibilitySettings() {
    guard let url = URL(
      string:
        "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    )
    else { return }
      
    NSWorkspace.shared.open(url)
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
    permissionStatusProvider()
  }
  
  func requestAuthorizationIfNeeded() -> Bool {
    let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
    return AXIsProcessTrustedWithOptions(options)
  }
}

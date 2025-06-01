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

/// Protocol for actively monitoring changes in Accessibility permission status.
@MainActor
protocol AccessibilityPermissionMonitoring {
  /// Starts monitoring accessibility permission status at regular intervals.
  ///
  /// - Parameter completion: Callback triggerred with the current permission state.
  func startMonitoring(completion: @escaping (_ permissionGranted: Bool) -> Void)

  /// Stops the ongoing permission monitoring.
  func stopMonitoring()
}

// MARK: - Permission Checking

/// Protocol for checking and requesting Accessibility permission,.
@MainActor
protocol AccessibilityPermissionChecking {
  /// Returns whether the application has Accessiblity permission.
  func isPermissionGranted() -> Bool

  /// Requests Accessibility permission if not already granted.
  ///
  /// - Returns: `true ` if permission is alreade granted or successfully prompted.
  func requestAuthorizationIfNeeded() -> Bool
}

// MARK: - Permission Settings Opener
/// Protocol for opening the system Accessibility settings pane.
@MainActor
protocol AccessibilityPermissionOpener {
  /// Opens the macOS System Settings app at the Accessibility section.
  func openAccessibilitySettings()
}

// MARK: - Permission Service

/// Composite type alias combining monitoring, checking, and settings navigation.
typealias AccessibilityPermissionService =
AccessibilityPermissionMonitoring
& AccessibilityPermissionChecking
& AccessibilityPermissionOpener

@Observable
final class AccessibilityPermissionHandler: AccessibilityPermissionService {

  /// Timer used for repeated permission checks.
  internal let permissionCheckTimer: AsyncTimer

  /// Closure that provides the current accessibility permission state.
  private let permissionStatusProvider: () -> Bool

  /// Current delat before the next permission check.
  private var currentInterval: Duration

  /// Fast check interval used when permission is not yet granted.
  private let fastInterval: Duration

  /// Backoff intervals used to slow down checks once permission is granted.
  private let backOffIntervals: [Duration]

  /// Intex of the current backoff interval.
  private var backOffIndex = 0

  // MARK: - Init

  /// Initializes a new permission handler
  ///
  /// - Parameters:
  ///   - fastInterval: Delay used between rapid permission checks.
  ///   - backoffIntervals: Sequence of increasing intervals after permission is granted.
  ///   - permissionCheckTimer: Timer implementation to schedule periodic checks.
  ///   - permissionStatusProvider: Closure returning current permission state (default uses `AXIsProcessTrusted()`).
  init(
    fastInterval: Duration = .seconds(3.0),
    backoffIntervals: [Duration] = [
      .seconds(0),
      .seconds(10),
      .seconds(30),
      .seconds(60),
      .seconds(120),
      .seconds(300)
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

  /// Opens macOS Accessibility settings pane to let user manually enable permission.
  func openAccessibilitySettings() {
    guard let url = URL(
      string:
        "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    )
    else { return }

    NSWorkspace.shared.open(url)
  }

  // MARK: - Monitoring

  /// Begins periodic checking of accessibility permission status.
  ///
  /// - Parameter completion: Called after each ckeck with the latest status.
  func startMonitoring(completion: @escaping (_ permissionGranted: Bool) -> Void) {
    scheduleTimer(completion: completion)
  }

  /// Stops any active monitoring of accessibility permission.
  func stopMonitoring() {
    permissionCheckTimer.cancel()
  }

  /// Schedules the timer to re-check permission at `currentInterval`.
  private func scheduleTimer(completion: @escaping (_ permissionGranted: Bool) -> Void) {
    permissionCheckTimer
      .start(interval: currentInterval, repeating: false) { [weak self] in
        guard let self else { return }
        Applog.print(
          context: .permissions,
          "Checking Accessibility permission…",
          "(next check in: \(currentInterval))"
        )
        let isGranted = isPermissionGranted()
        adjustMonitoringInterval(forPermission: isGranted)

        completion(isGranted)
        // Recursively reschedule next check
        scheduleTimer(completion: completion)
      }
  }

  /// Adjusts the interval between permission checks depending on whether permission is granted.
  private func adjustMonitoringInterval(forPermission granted: Bool) {
    if granted {
      // Use next backoff interval to reduce check frequency
      if backOffIndex < backOffIntervals.count - 1 {
        backOffIndex += 1
      }
      currentInterval = backOffIntervals[backOffIndex]
    } else {
      // Reset to fast interval, to check more aggressively
      backOffIndex = 0
      currentInterval = fastInterval
    }
  }

  // MARK: - Checking

  /// Checks whether the application currently has Accessibility permission.
  func isPermissionGranted() -> Bool {
    permissionStatusProvider()
  }

  /// Prompts the user for Accessibility permission if not already granted.
  ///
  /// - Returns: `true` if permission is granted or the prompt was shown.
  func requestAuthorizationIfNeeded() -> Bool {
    let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
    return AXIsProcessTrustedWithOptions(options)
  }
}

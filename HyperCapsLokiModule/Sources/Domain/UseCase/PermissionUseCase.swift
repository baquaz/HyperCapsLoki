//
//  PermissionsUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 27/04/2025.
//

import Foundation

/// Provides use cases for managing macOS accessibility permissions.
/// This includes checking, requesting, observing, and linking to System Settings.
@MainActor
public protocol AccessibilityPermissionUseCase {
  /// Opens the macOS System Settings to the Accessibility section.
  func openAccessibilityPermissionSettings()

  /// Ensures the app has the necessary accessibility permissions.
  /// - Returns: `true` if permission is already granted or successfully requested.
  func ensureAccessibilityPermissionsAreGranted() -> Bool

  /// Begins monitoring for changes in accessibility permission status.
  /// - Parameter completion: A callback that receives `true` if permission is granted, `false` otherwise.
  func monitorChanges(completion: @escaping (_ isPermissionGranted: Bool) -> Void)

  /// Stops monitoring for accessibility permission changes.
  func stopMonitoring()
}

public struct AccessibilityPermissionUseCaseImpl: AccessibilityPermissionUseCase {

  private let permissionService: AccessibilityPermissionService

  // MARK: - Init
  init(permissionService: AccessibilityPermissionService) {
    self.permissionService = permissionService
  }

  public func openAccessibilityPermissionSettings() {
    permissionService.openAccessibilitySettings()
  }

  /// Checks whether accessibility permissions are granted.
  /// If not, attempts to request them (if the system allows).
  /// - Returns: `true` if permission is granted or successfully requested, `false` otherwise.
  public func ensureAccessibilityPermissionsAreGranted() -> Bool {
    if permissionService.isPermissionGranted() {
      return true
    } else {
      return permissionService.requestAuthorizationIfNeeded()
    }
  }

  /// Starts monitoring the system for changes in accessibility permission status.
  /// This is useful for reacting to user actions in System Settings in real-time.
  public func monitorChanges(completion: @escaping (_ isPermissionGranted: Bool) -> Void) {
    permissionService.startMonitoring { isGranted in
      Applog.print(
        context: .permissions,
        "Permission granted:",
        isGranted ? "YES ✅" : "NO ❌"
      )
      completion(isGranted)
    }
  }

  /// Stops any ongoing monitoring of accessibility permission status.
  public func stopMonitoring() {
    permissionService.stopMonitoring()
  }
}

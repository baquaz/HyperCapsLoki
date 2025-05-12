//
//  PermissionsUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 27/04/2025.
//

import Foundation

@MainActor
public protocol AccessibilityPermissionUseCase {
  func openAccessibilityPermissionSettings()
  func ensureAccessibilityPermissionsAreGranted() -> Bool
  func monitorChanges(completion: @escaping (_ isPermissionGranted: Bool) -> Void)
  func stopMonitoring()
}

public struct AccessibilityPermissionUseCaseImpl: AccessibilityPermissionUseCase {
  
  private let permissionService: AccessibilityPermissionService
  
  init(permissionService: AccessibilityPermissionService) {
    self.permissionService = permissionService
  }
  
  public func openAccessibilityPermissionSettings() {
    permissionService.openAccessibilitySettings()
  }
  
  public func ensureAccessibilityPermissionsAreGranted() -> Bool {
    if permissionService.isPermissionGranted() {
      return true
    } else {
      return permissionService.requestAuthorizationIfNeeded()
    }
  }
  
  public func monitorChanges(completion: @escaping (_ isPermissionGranted: Bool) -> Void) {
    permissionService.startMonitoring() { isGranted in
      Applog.print(
        context: .permissions,
        "Permission granted:",
        isGranted ? "YES ✅" : "NO ❌"
      )
      completion(isGranted)
    }
  }
  
  public func stopMonitoring() {
    permissionService.stopMonitoring()
  }
}

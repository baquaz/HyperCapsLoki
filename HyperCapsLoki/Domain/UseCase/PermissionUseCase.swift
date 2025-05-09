//
//  PermissionsUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 27/04/2025.
//

import Foundation

@MainActor
protocol AccessibilityPermissionUseCase {
  func openAccessibilityPermissionSettings()
  func ensureAccessibilityPermissionsAreGranted() -> Bool
  func monitorChanges(completion: @escaping (_ isPermissionGranted: Bool) -> Void)
  func stopMonitoring()
}

struct AccessibilityPermissionUseCaseImpl: AccessibilityPermissionUseCase {
  
  private let permissionService: AccessibilityPermissionService
  
  init(permissionService: AccessibilityPermissionService) {
    self.permissionService = permissionService
  }
  
  func openAccessibilityPermissionSettings() {
    permissionService.openAccessibilitySettings()
  }
  
  func ensureAccessibilityPermissionsAreGranted() -> Bool {
    if permissionService.isPermissionGranted() {
      return true
    } else {
      return permissionService.requestAuthorizationIfNeeded()
    }
  }
  
  func monitorChanges(completion: @escaping (_ isPermissionGranted: Bool) -> Void) {
    permissionService.startMonitoring() { isGranted in
      print("[PERM]: usecase completion granted: \(isGranted)")
      completion(isGranted)
    }
  }
  
  func stopMonitoring() {
    permissionService.stopMonitoring()
  }
}

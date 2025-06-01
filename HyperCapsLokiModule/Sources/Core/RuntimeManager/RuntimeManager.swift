//
//  HyperkeyManager.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 26/01/2025.
//

import Foundation
import Cocoa

/// Protocol defining the runtime lifecycle behavior of the app.
@MainActor
protocol RuntimeProtocol {
  var appState: AppState? { get set }

  /// Starts the runtime logic (e.g. permission checks, feature setup).
  func start()

  /// Exits the runtime environment and cleans up resources.
  func exit()
}

final class RuntimeManager: RuntimeProtocol {
  internal weak var appState: AppState?

  /// Handler triggered after permission state changes are processed.
  internal var onPermissionChangedHandled: (() -> Void)?

  var environment: AppEnvironmentProtocol? {
    appState?.container?.environment
  }

  // MARK: - Init
  init(appState: AppState?) {
    self.appState = appState
  }

  // MARK: - Lifecycle

  /// Starts the app's runtime behavior:
  /// - Verifies if the app is set as a login item.
  /// - Saves login item sates.
  /// - Checks for Accessibility permission.
  /// - Launches main functionality if permission is granted.
  /// - Sets up continous monitoring of permission changes.
  func start() {
    let isLoginItem = environment?.loginItemUseCase.checkLoginItemEnabledStatus() ?? false
    environment?.loginItemUseCase.saveState(isLoginItem)

    let grantedPermission = environment?
      .permissionUseCase.ensureAccessibilityPermissionsAreGranted()

    if grantedPermission == true {
      appState?.accessibilityPermissionGranted = true
      environment?.launchUseCase.launch()
    } else {
      appState?.accessibilityPermissionGranted = false
    }

    setUpMonitoringPermission()
  }

  /// Exits the app:
  /// - Cancels permission monitoring.
  /// - Triggers environment-specific exit logic.
  func exit() {
    cancelMonitoringPermission()
    environment?.exitUseCase.exit()
  }

  // MARK: - Permission Monitoring

  /// Begins monitoring system-level Accessibility permission changes.
  ///
  /// If permission state changes (granted ↔ revoked), the app will:
  /// - Update `AppState.accessibilityPermissionGranted`.
  /// - Trigger relaunch logic if permission was granted.
  /// - Disable features (e.g., Hyperkey) if permission was revoked.
  /// - Call `onPermissionChangedHandled` after processing.
  internal func setUpMonitoringPermission() {
    environment?.permissionUseCase.monitorChanges { [weak self, weak appState] isPermissionGranted in
      guard let self, let appState else { return }

      let previousPermissionState = appState.accessibilityPermissionGranted
      guard isPermissionGranted != previousPermissionState else { return }

      appState.accessibilityPermissionGranted = isPermissionGranted

      Task {
        if isPermissionGranted {
          environment?.launchUseCase.launch()
        } else {
          // revoked permission
          environment?.hyperkeyFeatureUseCase
            .setHyperkeyFeature(active: false, forced: false)
        }

        onPermissionChangedHandled?()
      }
    }
  }

  /// Cancels permission monitoring to clean up resources when exiting.
  private func cancelMonitoringPermission() {
    environment?.permissionUseCase.stopMonitoring()
  }
}

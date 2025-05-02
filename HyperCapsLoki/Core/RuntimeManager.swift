//
//  HyperkeyManager.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 26/01/2025.
//

import Foundation
import Cocoa

@MainActor
protocol RuntimeProtocol {
  var appState: AppState? { get set }
  func start()
  func exit()
}

final class RuntimeManager: RuntimeProtocol {
  internal weak var appState: AppState?
  
  var environment: AppEnvironmentProtocol? {
    appState?.container?.environment
  }
  
  // MARK: - Init
  init(appState: AppState?) {
    self.appState = appState
  }

  func start() {
    let grantedPermission = environment?
      .permissionUseCase.ensureAccessibilityPermissionsAreGranted()
    
    if grantedPermission == true {
      appState?.accessibilityPermissionGranted = true
      environment?.launchUseCase.launch()
    } else {
      appState?.accessibilityPermissionGranted = false
      
      setUpMonitoringPermission()
    }
  }
  
  func exit() {
    cancelMonitoringPermission()
    environment?.exitUseCase.exit()
  }
  
  private func setUpMonitoringPermission() {
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
      }
    }
  }
  
  private func cancelMonitoringPermission() {
    environment?.permissionUseCase.stopMonitoring()
  }
}

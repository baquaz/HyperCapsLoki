//
//  AppLoginItemHandler.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 08/05/2025.
//

import Foundation
import ServiceManagement

/// Protocol defining login item management.
protocol AppLoginItemService {

  /// Checks if the login item is added to the system.
  /// - Returns: `true` if the app is gregistered as a login item.
  func checkStatus() -> Bool

  /// Registers the app as a login item.
  func register() throws

  /// Unregisters the app as a login item.
  func unregister() throws
}

final class AppLoginItemHandler: AppLoginItemService {
  func checkStatus() -> Bool {
    SMAppService.mainApp.status == .enabled
  }

  func register() throws {
    try SMAppService.mainApp.register()
  }

  func unregister() throws {
    try SMAppService.mainApp.unregister()
  }
}

//
//  AppLoginItemHandler.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 08/05/2025.
//

import Foundation
import ServiceManagement

protocol AppLoginItemService {
  func checkStatus() -> Bool
  func register() throws
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

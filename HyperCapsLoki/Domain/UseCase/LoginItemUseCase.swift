//
//  LoginItemUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 08/05/2025.
//

import Foundation

@MainActor
protocol LoginItemUseCase {
  func checkLoginItemEnabledStatus() -> Bool
  func setLoginItem(_ isEnabled: Bool) throws
  func saveState(_ isEnabled: Bool)
}

struct LoginItemUseCaseImpl: LoginItemUseCase {
  private let loginItemHandler: AppLoginItemService
  internal let storageRepository: StorageRepository
  
  // MARK: - Init
  init(
    loginItemHandler: any AppLoginItemService,
    storageRepository: any StorageRepository
  ) {
    self.loginItemHandler = loginItemHandler
    self.storageRepository = storageRepository
  }
  
  func checkLoginItemEnabledStatus() -> Bool {
    loginItemHandler.checkStatus()
  }
  
  func setLoginItem(_ isEnabled: Bool) throws {
    do {
      if isEnabled {
        try loginItemHandler.register()
      } else {
        try loginItemHandler.unregister()
      }
    }
    saveState(isEnabled)
  }
  
  func saveState(_ isEnabled: Bool) {
    storageRepository.setLoginItemEnabledState(isEnabled)
  }
}

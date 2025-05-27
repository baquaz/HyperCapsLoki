//
//  LoginItemUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 08/05/2025.
//

import Foundation

@MainActor
public protocol LoginItemUseCase {
  func checkLoginItemEnabledStatus() -> Bool
  func setLoginItem(_ isEnabled: Bool) throws
  func saveState(_ isEnabled: Bool)
}

public struct LoginItemUseCaseImpl: LoginItemUseCase {
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

  public func checkLoginItemEnabledStatus() -> Bool {
    loginItemHandler.checkStatus()
  }

  public func setLoginItem(_ isEnabled: Bool) throws {
    do {
      if isEnabled {
        try loginItemHandler.register()
      } else {
        try loginItemHandler.unregister()
      }
    }
    saveState(isEnabled)
  }

  public func saveState(_ isEnabled: Bool) {
    storageRepository.setLoginItemEnabledState(isEnabled)
  }
}

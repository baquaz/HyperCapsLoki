//
//  RemapUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

@MainActor
protocol RemapKeyUseCase {
  func execute(newKey: Key?)
}

final class RemapKeyUseCaseImpl: RemapKeyUseCase {
  private let keyStorageRepo: KeyStorageRepository
  private let eventsHandler: EventsHandler
  private let remapper: RemapExecutor
  
  init(
    keyStorageRepo: any KeyStorageRepository,
    eventsHandler: EventsHandler,
    remapper: any RemapExecutor
  ) {
    self.keyStorageRepo = keyStorageRepo
    self.eventsHandler = eventsHandler
    self.remapper = remapper
  }
  
  func execute(newKey: Key?) {
    if let newKey {
      remapper.remapUserKeyMappingCapsLock(using: newKey)
    } else {
      remapper.resetUserKeyMappingCapsLock()
    }
    eventsHandler.hyperKey = newKey
    keyStorageRepo.saveSelectedHyperkey(newKey)
  }
}

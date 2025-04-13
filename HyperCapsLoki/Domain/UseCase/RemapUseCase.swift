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
  private let storageRepo: StorageRepository
  private let eventsHandler: EventsHandler
  private let remapper: RemapExecutor
  
  init(
    storageRepo: any StorageRepository,
    eventsHandler: EventsHandler,
    remapper: any RemapExecutor
  ) {
    self.storageRepo = storageRepo
    self.eventsHandler = eventsHandler
    self.remapper = remapper
  }
  
  func execute(newKey: Key?) {
    let isHyperkeyFeatureActive = storageRepo.getHyperkeyFeatureState() == true
    
    if isHyperkeyFeatureActive {
      if let newKey {
        remapper.remapUserKeyMappingCapsLock(using: newKey)
      } else {
        remapper.resetUserKeyMappingCapsLock()
      }
    }
    
    eventsHandler.set(newKey)
    storageRepo.saveSelectedHyperkey(newKey)
  }
}

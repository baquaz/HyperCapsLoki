//
//  DisableUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 13/04/2025.
//

import Foundation

@MainActor
protocol HyperkeyFeatureUseCase {
  func setHyperkeyFeature(active: Bool)
  func getHyperkeySequenceKeysEnabled() -> [Key]
  func setHyperkeySequence(enabled: Bool, for key: Key)
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool)
}

final class HyperkeyFeatureUseCaseImpl: HyperkeyFeatureUseCase {
  private let storageRepository: StorageRepository
  private let eventsHandler: EventsHandler
  private let remapper: RemapExecutor

  init(
    storageRepository: StorageRepository,
    eventsHandler: EventsHandler,
    remapper: any RemapExecutor
  ) {
    self.eventsHandler = eventsHandler
    self.remapper = remapper
    self.storageRepository = storageRepository
  }
  
  func setHyperkeyFeature(active isActive: Bool) {
    eventsHandler.setEventTap(enabled: isActive)
    
    let selectedKey = storageRepository.getSelectedHyperkey()
    
    if isActive {
      if let selectedKey {
        remapper.remapUserKeyMappingCapsLock(using: selectedKey)
      }
    } else {
      remapper.resetUserKeyMappingCapsLock()
    }
    
    storageRepository.setHyperkeyFeatureState(isActive)
  }
  
  func getHyperkeySequenceKeysEnabled() -> [Key] {
    storageRepository.getHyperkeySequenceKeysEnabled()
  }
  
  func setHyperkeySequence(enabled isEnabled: Bool, for key: Key) {
    storageRepository.setHyperkeySequence(enabled: isEnabled, for: key)
    eventsHandler.set(
      availableSequenceKeys: storageRepository.getHyperkeySequenceKeysEnabled()
    )
  }
  
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool) {
    storageRepository.setHyperkeySequenceKeysAll(enabled: isEnabled)
    eventsHandler.set(
      availableSequenceKeys: storageRepository.getHyperkeySequenceKeysEnabled()
    )
  }
}

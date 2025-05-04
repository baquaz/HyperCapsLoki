//
//  RemapUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

@MainActor
protocol LaunchUseCase {
  func launch()
}

final class LaunchUseCaseImpl: LaunchUseCase {
  private let remapper: RemapExecutor
  private let eventsHandler: EventsHandler
  internal let storageRepository: StorageRepository
  
  // MARK: - Init
  init(
    remapper: any RemapExecutor,
    eventsHandler: EventsHandler,
    storageRepository: any StorageRepository
  ) {
    self.remapper = remapper
    self.eventsHandler = eventsHandler
    self.storageRepository = storageRepository
  }
  
  func launch() {
    let hyperkeyFeatureIsActive = storageRepository
      .getHyperkeyFeatureState() == true
    
    eventsHandler.setUpEventTap()
    if !hyperkeyFeatureIsActive {
      eventsHandler.setEventTap(enabled: false)
    }
    
    let selectedKey = storageRepository.getSelectedHyperkey()
    if let selectedKey, hyperkeyFeatureIsActive {
      remapper.remapUserKeyMappingCapsLock(using: selectedKey)
    }
    
    storageRepository.getHyperkeySequenceUnsetKeys().forEach {
      storageRepository.setHyperkeySequence(enabled: true, for: $0)
    }
    
    eventsHandler.set(selectedKey)
    eventsHandler.set(
      availableSequenceKeys: storageRepository.getHyperkeyEnabledSequenceKeys()
    )
  }
}

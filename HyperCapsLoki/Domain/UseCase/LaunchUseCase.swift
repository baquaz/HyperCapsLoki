//
//  RemapUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

@MainActor
protocol LaunchUseCase {
  func launch() async
}

final class LaunchUseCaseImpl: LaunchUseCase {
  private let remapper: RemapExecutor
  private let eventsHandler: EventsHandler
  private let keyStorageRepository: KeyStorageRepository
  
  // MARK: - Init
  init(
    remapper: any RemapExecutor,
    eventsHandler: EventsHandler,
    keyStorageRepository: any KeyStorageRepository
  ) {
    self.remapper = remapper
    self.eventsHandler = eventsHandler
    self.keyStorageRepository = keyStorageRepository
  }
  
  func launch() async {
    if keyStorageRepository.getSelectedHyperkey() == nil {
      keyStorageRepository.saveSelectedHyperkey(.f14)
    }
    
    guard let selectedKey = keyStorageRepository.getSelectedHyperkey() else { return }
    
    remapper.resetUserKeyMapping()
    remapper.remapUserKeyMappingCapsLock(using: selectedKey)
    
    eventsHandler.hyperKey = selectedKey
    eventsHandler.setupEventTap()
  } 
}

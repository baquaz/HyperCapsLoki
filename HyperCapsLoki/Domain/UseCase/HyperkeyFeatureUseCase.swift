//
//  DisableUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 13/04/2025.
//

import Foundation

@MainActor
protocol HyperkeyFeatureUseCase: AnyObject {
  /// Changes **Hyperkey** feature forced by user,
  /// or passively by the system (i.e. due to permission changes)
  ///
  /// - Parameters:
  ///   - isActive: enables or disables Hyperkey feature
  ///   - forced:
  ///     If `true` - disables feature totally,
  ///     If `false` -  disables feature, but remains state (UI) for future reactivation
  ///
  func setHyperkeyFeature(active isActive: Bool, forced: Bool)
  
  func getHyperkeyEnabledSequenceKeys() -> [Key]
  
  func setHyperkeySequence(enabled: Bool, for key: Key)
  
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool)
}

final class HyperkeyFeatureUseCaseImpl: HyperkeyFeatureUseCase {
  internal let storageRepository: StorageRepository
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
  
  func setHyperkeyFeature(active isActive: Bool, forced: Bool) {
    eventsHandler.setEventTap(enabled: isActive)
    
    let selectedKey = storageRepository.getSelectedHyperkey()
    
    if isActive {
      if let selectedKey {
        remapper.remapUserKeyMappingCapsLock(using: selectedKey)
      }
    } else {
      if storageRepository.getHyperkeyFeatureState() == true {
        remapper.resetUserKeyMappingCapsLock()
      }
    }
    
    if forced {
      storageRepository.setHyperkeyFeatureState(isActive)
    }
  }
  
  func getHyperkeyEnabledSequenceKeys() -> [Key] {
    storageRepository.getHyperkeyEnabledSequenceKeys()
  }
  
  func setHyperkeySequence(enabled isEnabled: Bool, for key: Key) {
    storageRepository.setHyperkeySequence(enabled: isEnabled, for: key)
    eventsHandler.set(
      availableSequenceKeys: storageRepository.getHyperkeyEnabledSequenceKeys()
    )
  }
  
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool) {
    storageRepository.setHyperkeySequenceKeysAll(enabled: isEnabled)
    eventsHandler.set(
      availableSequenceKeys: storageRepository.getHyperkeyEnabledSequenceKeys()
    )
  }
}

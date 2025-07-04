//
//  DisableUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 13/04/2025.
//

import Foundation

@MainActor
public protocol HyperkeyFeatureUseCase: AnyObject {
  /// Changes **Hyperkey** feature forced by user,
  /// or passively by the system (e.g., due to permission changes)
  ///
  /// - Parameters:
  ///   - isActive: enables or disables Hyperkey feature
  ///   - forced:
  ///     If `true` - disables feature totally,
  ///     If `false` -  disables feature, but remains state (UI) for future reactivation
  func setHyperkeyFeature(active isActive: Bool, forced: Bool)

  func getHyperkeyEnabledSequenceKeys() -> [Key]

  func setHyperkeySequence(enabled: Bool, for key: Key)

  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool)
}

public final class HyperkeyFeatureUseCaseImpl: HyperkeyFeatureUseCase {
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

  public func setHyperkeyFeature(active isActive: Bool, forced: Bool) {
    eventsHandler.setEventTap(enabled: isActive)

    let selectedKey = storageRepository.getSelectedHyperkey()

    if isActive {
      // If feature is active and a key is selected, remap Caps Lock
      if let selectedKey {
        remapper.remapUserKeyMappingCapsLock(using: selectedKey)
      }
    } else {
      // Only reset remapping if feature was previously active
      if storageRepository.getHyperkeyFeatureState() == true {
        remapper.resetUserKeyMappingCapsLock()
      }
    }

    // If forced, update persistent state to fully reflect current activation status
    if forced {
      storageRepository.setHyperkeyFeatureState(isActive)
    }
  }

  public func getHyperkeyEnabledSequenceKeys() -> [Key] {
    storageRepository.getHyperkeyEnabledSequenceKeys()
  }

  public func setHyperkeySequence(enabled isEnabled: Bool, for key: Key) {
    storageRepository.setHyperkeySequence(enabled: isEnabled, for: key)
    eventsHandler.set(
      availableSequenceKeys: storageRepository.getHyperkeyEnabledSequenceKeys()
    )
  }

  public func setHyperkeySequenceKeysAll(enabled isEnabled: Bool) {
    storageRepository.setHyperkeySequenceKeysAll(enabled: isEnabled)
    eventsHandler.set(
      availableSequenceKeys: storageRepository.getHyperkeyEnabledSequenceKeys()
    )
  }
}

//
//  RemapUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

/// Handles post-permission setup for Hyperkey functionality,
/// including key remapping, sequence activation, and event tap initialization.
@MainActor
public protocol LaunchUseCase {
  /// Initializes the Hyperkey feature after permissions are granted.
  /// This includes key remapping, event tap setup, and user-preference syncing.
  func launch()
}

public final class LaunchUseCaseImpl: LaunchUseCase {
  private let loginItemHandler: AppLoginItemService
  private let remapper: RemapExecutor
  private let eventsHandler: EventsHandler
  internal let storageRepository: StorageRepository

  // MARK: - Init
  init(
    loginItemHandler: any AppLoginItemService,
    remapper: any RemapExecutor,
    eventsHandler: EventsHandler,
    storageRepository: any StorageRepository
  ) {
    self.loginItemHandler = loginItemHandler
    self.remapper = remapper
    self.eventsHandler = eventsHandler
    self.storageRepository = storageRepository
  }

  /// Initializes the Hyperkey-related components after accessibility permission is granted.
  /// - Sets up event tap
  /// - Applies key remapping if feature is active
  /// - Syncs sequence keys and user preferences
  public func launch() {
    let hyperkeyFeatureIsActive = storageRepository
      .getHyperkeyFeatureState() == true

    // Prepare global keyboard event interception
    eventsHandler.setUpEventTap()

    // Disable tap unless feature is active
    if !hyperkeyFeatureIsActive {
      eventsHandler.setEventTap(enabled: false)
    }

    // Apply key remapping if the feature is active and key is selected
    let selectedKey = storageRepository.getSelectedHyperkey()
    if let selectedKey, hyperkeyFeatureIsActive {
      remapper.remapUserKeyMappingCapsLock(using: selectedKey)
    }

    // Enable all unset hyperkey sequence keys by default
    storageRepository.getHyperkeySequenceUnsetKeys().forEach {
      storageRepository.setHyperkeySequence(enabled: true, for: $0)
    }

    // Sync event handler with active key and enabled sequence keys
    eventsHandler.set(selectedKey)
    eventsHandler.set(
      availableSequenceKeys: storageRepository.getHyperkeyEnabledSequenceKeys()
    )
  }
}

//
//  AppMenuViewModel.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class AppMenuViewModel {
  // MARK: Sequence
  let availableKeys: [Key?] =
    [nil] // none key
    + Key.allCases.filter { $0 != .capsLock }
  let allHyperkeySequenceKeys: [Key]
  
  // MARK: Feature
  var isHyperkeyFeatureActive: Bool
  var selectedKey: Key?
  
  private let defaultHyperkey: Key
  private var enabledHyperkeySequenceKeys: [Key]
  
  // MARK: Colors
  private let colorsPalette: [Int: Color] = [
    0 : .themeTertiary,
    1 : .themeSecondary,
    2 : .themePrimary,
    3 : .themeBold
  ]
  
  // MARK: Use Cases
  private let hyperkeyFeatureUseCase: HyperkeyFeatureUseCase
  private let remapKeyUseCase: RemapKeyUseCase
  private let exitUseCase: ExitUseCase
  
  // MARK: - Init
  init(
    defaultHyperkey: Key,
    storageRepository: StorageRepository,
    hyperkeyFeatureUseCase: HyperkeyFeatureUseCase,
    remapKeyUseCase: RemapKeyUseCase,
    exitUseCase: ExitUseCase
  ) {
    self.defaultHyperkey = defaultHyperkey
    self.hyperkeyFeatureUseCase = hyperkeyFeatureUseCase
    self.remapKeyUseCase = remapKeyUseCase
    self.exitUseCase = exitUseCase
    
    allHyperkeySequenceKeys = Key.allHyperkeySequenceKeys
    enabledHyperkeySequenceKeys = storageRepository.getHyperkeySequenceKeysEnabled()
    
    isHyperkeyFeatureActive = storageRepository.getHyperkeyFeatureState() ?? true
    selectedKey = storageRepository.getSelectedHyperkey()
  }
  
  // MARK: - Hyperkey Sequence Keys
  func isSequenceEnabled(for key: Key) -> Bool {
    enabledHyperkeySequenceKeys.contains(key) && isHyperkeyFeatureActive
  }
  
  func getSequenceColor(for index: Int) -> Color {
    colorsPalette[index] ?? .clear
  }
  
  // MARK: - Text for Key
  func getTextForKey(_ key: Key?) -> String {
    guard let key else { return "- no key -" }
    return key.rawValue + (key == defaultHyperkey ? " (default)" : "")
  }
  
  // MARK: - Actions
  @MainActor
  func setActiveStatus(_ isActive: Bool) {
    isHyperkeyFeatureActive = isActive
    hyperkeyFeatureUseCase.setHyperkeyFeature(active: isActive, forced: true)
  }
  
  @MainActor
  func setHyperkeySequence(enabled isEnabled: Bool, for key: Key) {
    if isEnabled {
      enabledHyperkeySequenceKeys.append(key)
    } else {
      enabledHyperkeySequenceKeys.removeAll { $0 == key }
    }
    hyperkeyFeatureUseCase.setHyperkeySequence(enabled: isEnabled, for: key)
  }
  
  @MainActor
  func onSelectKey(_ key: Key?, shouldUpdate: Bool = false) {
    if shouldUpdate { selectedKey = key }
    remapKeyUseCase.execute(newKey: key)
  }
  
  @MainActor
  func resetRemappingToDefault() {
    onSelectKey(defaultHyperkey, shouldUpdate: true)
  }
  
  @MainActor
  func resetAll() {
    setActiveStatus(true)
    onSelectKey(nil, shouldUpdate: true)
    hyperkeyFeatureUseCase.setHyperkeySequenceKeysAll(enabled: true)
    enabledHyperkeySequenceKeys = hyperkeyFeatureUseCase
      .getHyperkeySequenceKeysEnabled()
  }
  
  @MainActor
  func quit() {
    exitUseCase.terminate()
  }
}

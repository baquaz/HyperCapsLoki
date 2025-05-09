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
  var isOpenAtLoginEnabled: Bool
  var isHyperkeyFeatureActive: Bool
  var selectedKey: Key?
  
  internal let defaultHyperkey: Key
  internal var hyperkeyEnabledSequenceKeys: [Key]
  
  // MARK: Colors
  private let colorsPalette: [Int: Color] = [
    0 : .themeTertiary,
    1 : .themeSecondary,
    2 : .themePrimary,
    3 : .themeBold
  ]
  
  // MARK: Use Cases
  internal let loginItemUseCase: LoginItemUseCase
  internal let permissionUseCase: AccessibilityPermissionUseCase
  internal let hyperkeyFeatureUseCase: HyperkeyFeatureUseCase
  internal let remapKeyUseCase: RemapKeyUseCase
  internal let exitUseCase: ExitUseCase
  
  // MARK: - Init
  init(
    defaultHyperkey: Key,
    storageRepository: StorageRepository,
    loginItemUseCase: LoginItemUseCase,
    permissionUseCase: AccessibilityPermissionUseCase,
    hyperkeyFeatureUseCase: HyperkeyFeatureUseCase,
    remapKeyUseCase: RemapKeyUseCase,
    exitUseCase: ExitUseCase
  ) {
    self.defaultHyperkey = defaultHyperkey
    self.loginItemUseCase = loginItemUseCase
    self.permissionUseCase = permissionUseCase
    self.hyperkeyFeatureUseCase = hyperkeyFeatureUseCase
    self.remapKeyUseCase = remapKeyUseCase
    self.exitUseCase = exitUseCase
    
    allHyperkeySequenceKeys = Key.allHyperkeySequenceKeys
    hyperkeyEnabledSequenceKeys = storageRepository.getHyperkeyEnabledSequenceKeys()
    
    isOpenAtLoginEnabled = storageRepository.getLoginItemEnabledState()
    isHyperkeyFeatureActive = storageRepository.getHyperkeyFeatureState() ?? true
    selectedKey = storageRepository.getSelectedHyperkey()
  }
  
  // MARK: - Hyperkey Sequence Keys
  func isSequenceEnabled(for key: Key) -> Bool {
    hyperkeyEnabledSequenceKeys.contains(key) && isHyperkeyFeatureActive
  }
  
  @MainActor
  func setHyperkeySequence(enabled isEnabled: Bool, for key: Key) {
    if isEnabled {
      hyperkeyEnabledSequenceKeys.append(key)
    } else {
      hyperkeyEnabledSequenceKeys.removeAll { $0 == key }
    }
    hyperkeyFeatureUseCase.setHyperkeySequence(enabled: isEnabled, for: key)
  }
  
  // MARK: - Sequence Item Color
  func getSequenceColor(for index: Int) -> Color {
    colorsPalette[index] ?? .clear
  }
  
  // MARK: - Text for Key
  func getTextForKey(_ key: Key?) -> String {
    guard let key else { return "- no key -" }
    return key.rawValue + (key == defaultHyperkey ? " (default)" : "")
  }
  
  // MARK: - Actions
  func setLoginItem(_ isEnabled: Bool) {
    do {
      try loginItemUseCase.setLoginItem(isEnabled)
      isOpenAtLoginEnabled = isEnabled
    } catch {
      print("Error setting login item: \(error)")
    }
  }
  
  func openAccessibilityPermissionSettings() {
    permissionUseCase.openAccessibilityPermissionSettings()
  }
  
  @MainActor
  func setActiveStatus(_ isActive: Bool) {
    isHyperkeyFeatureActive = isActive
    hyperkeyFeatureUseCase.setHyperkeyFeature(active: isActive, forced: true)
  }
  
  @MainActor
  func onSelectKey(_ key: Key?) {
    selectedKey = key
    remapKeyUseCase.execute(newKey: key)
  }
  
  @MainActor
  func resetRemappingToDefault() {
    onSelectKey(defaultHyperkey)
  }
  
  @MainActor
  func resetAll() {
    setActiveStatus(true)
    onSelectKey(nil)
    hyperkeyFeatureUseCase.setHyperkeySequenceKeysAll(enabled: true)
    hyperkeyEnabledSequenceKeys = hyperkeyFeatureUseCase
      .getHyperkeyEnabledSequenceKeys()
    setLoginItem(false)
  }
  
  @MainActor
  func quit() {
    exitUseCase.terminate()
  }
}

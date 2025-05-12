//
//  AppMenuViewModel.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation
import SwiftUI
import SharedAssets
import AppLogger

@Observable
@MainActor
public final class AppMenuViewModel {
  // MARK: Sequence
  public let availableKeys: [Key?] =
    [nil] // none key
    + Key.allCases.filter { $0 != .capsLock }
  public let allHyperkeySequenceKeys: [Key]
  
  // MARK: Feature
  public var isOpenAtLoginEnabled: Bool
  public var isHyperkeyFeatureActive: Bool
  public var selectedKey: Key?
  
  internal let defaultHyperkey: Key
  internal var hyperkeyEnabledSequenceKeys: [Key]
  
  // MARK: Colors
  private var colorsPalette: [Int: Color] = [:]
  
//  // MARK: - Logs Save Result
  public var onSaveLogs: (() -> Void)?
  
  // MARK: Use Cases
  internal let loginItemUseCase: LoginItemUseCase
  internal let permissionUseCase: AccessibilityPermissionUseCase
  internal let hyperkeyFeatureUseCase: HyperkeyFeatureUseCase
  internal let remapKeyUseCase: RemapKeyUseCase
  internal let exitUseCase: ExitUseCase
  
  // MARK: - Init
  public init(
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
    hyperkeyEnabledSequenceKeys = storageRepository
      .getHyperkeyEnabledSequenceKeys()
    
    isOpenAtLoginEnabled = storageRepository.getLoginItemEnabledState()
    isHyperkeyFeatureActive = storageRepository
      .getHyperkeyFeatureState() ?? true
    selectedKey = storageRepository.getSelectedHyperkey()
    
    setSequenceColorsPalette()
  }
  
  private func setSequenceColorsPalette() {
    colorsPalette = [
      0 : SharedAssets.themeTertiary,
      1 : SharedAssets.themeSecondary,
      2 : SharedAssets.themePrimary,
      3 : SharedAssets.themeBold
    ]
  }
  
  // MARK: - Hyperkey Sequence Keys
  public func isSequenceEnabled(for key: Key) -> Bool {
    hyperkeyEnabledSequenceKeys.contains(key) && isHyperkeyFeatureActive
  }
  
  @MainActor
  public func setHyperkeySequence(enabled isEnabled: Bool, for key: Key) {
    if isEnabled {
      hyperkeyEnabledSequenceKeys.append(key)
    } else {
      hyperkeyEnabledSequenceKeys.removeAll { $0 == key }
    }
    hyperkeyFeatureUseCase.setHyperkeySequence(enabled: isEnabled, for: key)
  }
  
  // MARK: - Sequence Item Color
  public func getSequenceColor(for index: Int) -> Color {
    colorsPalette[index] ?? .clear
  }
  
  // MARK: - Text for Key
  public func getTextForKey(_ key: Key?) -> String {
    guard let key else { return "- no key -" }
    return key.rawValue + (key == defaultHyperkey ? " (default)" : "")
  }
  
  // MARK: - Actions
  public func setLoginItem(_ status: Bool) {
    let currentStatus = loginItemUseCase.checkLoginItemEnabledStatus()
    guard status != currentStatus else { return }
    
    do {
      try loginItemUseCase.setLoginItem(status)
      isOpenAtLoginEnabled = status
      Applog.print(tag: .success, context: .application,
                   "Set app launch at login to:", status ? "YES ✅": "NO ❌")
    } catch {
      Applog.print(tag: .error, context: .application,
                   "Error setting login item failed!", error, separator: "\n")
    }
  }
  
  public func openAccessibilityPermissionSettings() {
    permissionUseCase.openAccessibilityPermissionSettings()
  }
  
  @MainActor
  public func setActiveStatus(_ isActive: Bool) {
    isHyperkeyFeatureActive = isActive
    hyperkeyFeatureUseCase.setHyperkeyFeature(active: isActive, forced: true)
    Applog.print(context: .hyperkey,
                 "Hyperkey feature is now:", isActive ? "ON ✅" : "OFF ❌")
  }
  
  @MainActor
  public func onSelectKey(_ key: Key?) {
    selectedKey = key
    remapKeyUseCase.execute(newKey: key)
  }
  
  @MainActor
  public func resetRemappingToDefault() {
    // Automatically triggers UI key picker update and `onChange` listener
    selectedKey = defaultHyperkey
  }
  
  @MainActor
  public func triggerSaveLogs() {
    onSaveLogs?()
  }
  
  @available(*, unavailable, message: "No needed for now")
  @MainActor
  public func clearSavedLogsResult() { }
  
  @MainActor
  public func resetAll() {
    Applog.print(context: .application, "Settings Reset all...")
    setActiveStatus(true)
    
    // Automatically triggers UI key picker update and `onChange` listener
    selectedKey = nil
    
    hyperkeyFeatureUseCase.setHyperkeySequenceKeysAll(enabled: true)
    hyperkeyEnabledSequenceKeys = hyperkeyFeatureUseCase
      .getHyperkeyEnabledSequenceKeys()
    
    setLoginItem(false)
  }
  
  @MainActor
  public func quit() {
    exitUseCase.terminate()
  }
}

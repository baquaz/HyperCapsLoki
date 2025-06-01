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

/// View model for the app's menu UI, managing user interactions
/// and syncing state with underlying use cases (e.g., remapping, permissions).
@Observable
@MainActor
public final class AppMenuViewModel {
  // MARK: - Sequence

  /// All available keys the user can choose for remapping, excluding Caps Lock.
  public let availableRemappingKeys: [Key?] =
    [nil] // none key
    + Key.allCases.filter { $0 != .capsLock }

  /// Static list of all Hyperkey sequence-compatible keys.
  public let allHyperkeySequenceKeys: [Key]

  // MARK: - Feature State

  /// Indicates whether the app launches at login.
  public var isOpenAtLoginEnabled: Bool

  /// Indicates whether the Hyperkey feature is currently active.
  public var isHyperkeyFeatureActive: Bool

  /// The currently selected Hyperkey.
  public var selectedKey: Key?

  /// Default fallback key used for Hyperkey remapping.
  internal let defaultHyperkey: Key

  /// Cached list of currently active sequence keys.
  internal var hyperkeyEnabledSequenceKeys: [Key]

  // MARK: - Visuals

  /// Color palette used for coloring sequence items by index.
  private var colorsPalette: [Int: Color] = [:]

  // MARK: - Events

  /// Triggered when logs should be saved.
  public var onSaveLogs: (() -> Void)?

  /// Triggered when the "About" screen should be presented.
  public var onPresentingAbout: (() -> Void)?

  // MARK: - Use Cases

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
      0: SharedAssets.themeTertiary,
      1: SharedAssets.themeSecondary,
      2: SharedAssets.themePrimary,
      3: SharedAssets.themeBold
    ]
  }

  // MARK: - Sequence Keys

  /// Checks whether a sequence key is currently enabled and usable.
  public func isSequenceEnabled(for key: Key) -> Bool {
    hyperkeyEnabledSequenceKeys.contains(key) && isHyperkeyFeatureActive
  }

  /// Updates the enabled state of a sequence key and syncs it with the use case.
  @MainActor
  public func setHyperkeySequence(enabled isEnabled: Bool, for key: Key) {
    if isEnabled {
      hyperkeyEnabledSequenceKeys.append(key)
    } else {
      hyperkeyEnabledSequenceKeys.removeAll { $0 == key }
    }
    hyperkeyFeatureUseCase.setHyperkeySequence(enabled: isEnabled, for: key)
  }

  // MARK: - UI Helpers

  public func getSequenceColor(for index: Int) -> Color {
    colorsPalette[index] ?? .clear
  }

  public func getTextForKey(_ key: Key?) -> String {
    guard let key else { return "- no key -" }
    return key.rawValue + (key == defaultHyperkey ? " (default)" : "")
  }

  // MARK: - User Actions

  /// Toggles the "open at login" setting and persists it.
  public func setLoginItem(_ status: Bool) {
    let currentStatus = loginItemUseCase.checkLoginItemEnabledStatus()
    guard status != currentStatus else { return }

    do {
      try loginItemUseCase.setLoginItem(status)
      isOpenAtLoginEnabled = status

      Applog.print(
        tag: .success,
        context: .application,
        "Set app launch at login to:",
        status ? "YES ✅" : "NO ❌"
      )
    } catch {
      Applog.print(
        tag: .error,
        context: .application,
        "Error setting login item failed!",
        error,
        separator: "\n"
      )
    }
  }

  public func openAccessibilityPermissionSettings() {
    permissionUseCase.openAccessibilityPermissionSettings()
  }

  /// Enables or disables the Hyperkey feature.
  @MainActor
  public func setActiveStatus(_ isActive: Bool) {
    isHyperkeyFeatureActive = isActive
    hyperkeyFeatureUseCase.setHyperkeyFeature(active: isActive, forced: true)

    Applog.print(
      context: .hyperkey,
      "Hyperkey feature is now:",
      isActive ? "ON ✅" : "OFF ❌"
    )
  }

  /// Updates the selected remap key.
  @MainActor
  public func onSelectKey(_ key: Key?) {
    selectedKey = key
    remapKeyUseCase.execute(newKey: key)
  }

  /// Resets selected key to the default remap key.
  @MainActor
  public func resetRemappingToDefault() {
    // Automatically triggers UI key picker update and `onChange` listener
    selectedKey = defaultHyperkey
  }

  @MainActor
  public func triggerSaveLogs() {
    onSaveLogs?()
  }

  @MainActor
  public func triggerAbout() {
    onPresentingAbout?()
  }

  /// Resets app settings, sequences, and key selection to default state.
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

  /// Exits the app cleanly via `ExitUseCase`.
  @MainActor
  public func quit() {
    exitUseCase.terminate()
  }
}

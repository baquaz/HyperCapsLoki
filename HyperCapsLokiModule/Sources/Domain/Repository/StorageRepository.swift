//
//  StorageRepository.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

@MainActor
public protocol StorageRepository {
  var dataSource: StorageProtocol { get set }

  // MARK: - Login Item State
  func getLoginItemEnabledState() -> Bool
  func setLoginItemEnabledState(_ isEnabled: Bool)

  // MARK: - Hyperkey Feature
  func getHyperkeyFeatureState() -> Bool?
  func setHyperkeyFeatureState(_ isActive: Bool)

  // MARK: - Hyperkey Key
  func getSelectedHyperkey() -> Key?
  func saveSelectedHyperkey(_ key: Key?)

  // MARK: - Hyperkey Sequence
  func getHyperkeySequenceUnsetKeys() -> [Key]
  func getHyperkeyEnabledSequenceKeys() -> [Key]
  func setHyperkeySequence(enabled isEnabled: Bool, for key: Key)
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool)
}

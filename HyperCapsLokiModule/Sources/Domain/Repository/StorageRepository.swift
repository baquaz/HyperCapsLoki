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

  func getLoginItemEnabledState() -> Bool
  func setLoginItemEnabledState(_ isEnabled: Bool)

  func getHyperkeyFeatureState() -> Bool?
  func setHyperkeyFeatureState(_ isActive: Bool)

  func getSelectedHyperkey() -> Key?
  func saveSelectedHyperkey(_ key: Key?)

  func getHyperkeySequenceUnsetKeys() -> [Key]
  func getHyperkeyEnabledSequenceKeys() -> [Key]
  func setHyperkeySequence(enabled isEnabled: Bool, for key: Key)
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool)
}

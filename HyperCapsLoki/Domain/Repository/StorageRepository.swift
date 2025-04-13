//
//  StorageRepository.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

@MainActor
protocol StorageRepository {
  func getHyperkeyFeatureState() -> Bool?
  func setHyperkeyFeatureState(_ isActive: Bool)
  
  func getSelectedHyperkey() -> Key?
  func saveSelectedHyperkey(_ key: Key?)
  
  func getHyperkeySequenceKeysUnset() -> [Key]
  func getHyperkeySequenceKeysEnabled() -> [Key]
  func setHyperkeySequence(enabled isEnabled: Bool, for key: Key)
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool)
}

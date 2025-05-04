//
//  StorageRepositoryImpl.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

final class StorageRepositoryImpl: StorageRepository {
  
  internal var dataSource: StorageProtocol
  
  // MARK: - Init
  init(dataSource: StorageProtocol) {
    self.dataSource = dataSource
  }
  
  func getHyperkeyFeatureState() -> Bool? {
    dataSource.isHyperkeyFeatureActive
  }
  
  func setHyperkeyFeatureState(_ isActive: Bool) {
    dataSource.isHyperkeyFeatureActive = isActive
  }
  
  func getSelectedHyperkey() -> Key? {
    Key(rawValue: dataSource.selectedHyperkey ?? "")
  }
  
  func saveSelectedHyperkey(_ key: Key?) {
    dataSource.selectedHyperkey = key?.rawValue
  }
  
  func getHyperkeySequenceUnsetKeys() -> [Key] {
    Key.allHyperkeySequenceKeys.filter { dataSource[$0] == nil }
  }
  
  func getHyperkeyEnabledSequenceKeys() -> [Key] {
    Key.allHyperkeySequenceKeys.filter { dataSource[$0] == true }
  }
  
  func setHyperkeySequence(enabled isEnabled: Bool, for key: Key) {
    if Key.allHyperkeySequenceKeys.contains(key) {
      dataSource[key] = isEnabled
    }
  }
  
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool) {
    Key.allHyperkeySequenceKeys.forEach { dataSource[$0] = isEnabled }
  }
  
}

//
//  KeyStorageRepositoryImpl.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

final class KeyStorageRepositoryImpl: KeyStorageRepository {
  private let dataSource: KeyStorage
  
  init(dataSource: KeyStorage) {
    self.dataSource = dataSource
  }
  
  func getSelectedHyperkey() -> Key? {
    Key(rawValue: dataSource.selectedHyperkey ?? "")
  }
  
  func saveSelectedHyperkey(_ key: Key?) {
    dataSource.selectedHyperkey = key?.rawValue
  }
}

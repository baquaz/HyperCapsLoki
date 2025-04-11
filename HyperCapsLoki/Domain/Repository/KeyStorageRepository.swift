//
//  KeyStorageRepository.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

protocol KeyStorageRepository {
  func getSelectedHyperkey() -> Key?
  func saveSelectedHyperkey(_ key: Key?)
}

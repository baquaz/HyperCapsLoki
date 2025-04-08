//
//  AppMenuViewModel.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation
import SwiftUI

@Observable
final class AppMenuViewModel {
  let availableKeys: [Key]
  let defaultKey: Key = .f14
  
  var selectedKey: Key
  
  private let keyStorageRepository: KeyStorageRepository
  private let remapKeyUseCase: RemapKeyUseCase
  
  init(
    keyStorageRepository: KeyStorageRepository,
    remapKeyUseCase: RemapKeyUseCase
  ) {
    self.keyStorageRepository = keyStorageRepository
    self.remapKeyUseCase = remapKeyUseCase
    self.selectedKey = keyStorageRepository.getSelectedHyperkey() ?? defaultKey
    self.availableKeys = Key.allCases.filter { $0 != .capsLock }
  }
  
  func textForKey(_ key: Key) -> String {
    guard key == defaultKey else { return key.rawValue }
    return key.rawValue + (selectedKey != defaultKey ? " (default)" : "")
  }
  
  @MainActor
  func onSelectKey(_ key: Key) {
    keyStorageRepository.saveSelectedHyperkey(key)
    selectedKey = key
    remapKeyUseCase.execute(newKey: key)
  }
  
  @MainActor
  func resetToDefault() {
    onSelectKey(defaultKey)
  }
}

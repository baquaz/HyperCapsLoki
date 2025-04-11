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
  let availableKeys: [Key?] =
    [nil] // none key
    + Key.allCases.filter { $0 != .capsLock }
  
  let defaultKey: Key = .f14
  
  var selectedKey: Key?
  
  private let remapKeyUseCase: RemapKeyUseCase
  
  init(
    keyStorageRepository: KeyStorageRepository,
    remapKeyUseCase: RemapKeyUseCase
  ) {
    self.remapKeyUseCase = remapKeyUseCase
    self.selectedKey = keyStorageRepository.getSelectedHyperkey()
  }
  
  func textForKey(_ key: Key?) -> String {
    guard let key else { return "----" }
    if key == defaultKey {
      return key.rawValue + (selectedKey != defaultKey ? " (default)" : "")
    } else {
      return key.rawValue
    }
  }
  
  @MainActor
  func onSelectKey(_ key: Key?) {
    selectedKey = key
    remapKeyUseCase.execute(newKey: key)
  }
  
  @MainActor
  func resetToDefault() {
    onSelectKey(defaultKey)
  }
}

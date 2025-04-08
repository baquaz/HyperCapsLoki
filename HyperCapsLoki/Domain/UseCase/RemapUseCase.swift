//
//  RemapUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

@MainActor
protocol RemapKeyUseCase {
  func execute(newKey: Key)
}

final class RemapKeyUseCaseImpl: RemapKeyUseCase {
  private let keyStorageRepo: KeyStorageRepository
  private let remapper: RemapExecutor
  
  init(keyStorageRepo: any KeyStorageRepository, remapper: any RemapExecutor) {
    self.keyStorageRepo = keyStorageRepo
    self.remapper = remapper
  }
  
  func execute(newKey: Key) {
    keyStorageRepo.saveSelectedHyperkey(newKey)
    remapper.remapUserKeyMappingCapsLock(using: newKey)
  }
}

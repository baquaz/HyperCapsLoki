//
//  TestEnvironment+Domain.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 08/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

// MARK: - Domain
extension TestEnvironment {

  @MainActor
  @discardableResult
  func withStorageRepository(_ storageRepository: StorageRepository? = nil)
  -> Self {
    var copy = self
    copy.storageRepository = storageRepository ?? StorageRepositoryImpl(
      dataSource: copy.storage)
    return copy
  }
}

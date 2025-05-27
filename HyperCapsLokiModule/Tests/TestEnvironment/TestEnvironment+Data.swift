//
//  TestEnvironment+Data.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 08/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

// MARK: - Data
extension TestEnvironment {

  @discardableResult
  func withStorage(_ storage: StorageProtocol = MockStorage()) -> Self {
    var copy = self
    copy.storage = storage
    return copy
  }
}

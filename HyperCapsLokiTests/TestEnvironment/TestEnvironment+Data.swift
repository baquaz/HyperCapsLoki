//
//  TestEnvironment+Data.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 08/05/2025.
//

import Foundation
@testable import HyperCapsLoki

// MARK: - Data
extension TestEnvironment {
  
  @discardableResult
  func makeStorage(_ storage: StorageProtocol = MockStorage()) -> Self {
    var copy = self
    copy.storage = storage
    return copy
  }
}

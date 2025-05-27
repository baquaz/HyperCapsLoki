//
//  MockRemapper.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

final class MockRemapper: RemapExecutor {
  var receivedRemappingCapsLockKey: Key?
  var resetUserKeyMappingCapsLockCalled = false

  func remapUserKeyMappingCapsLock(using key: Key) {
    receivedRemappingCapsLockKey = key
  }

  func resetUserKeyMappingCapsLock() {
    resetUserKeyMappingCapsLockCalled = true
  }
}

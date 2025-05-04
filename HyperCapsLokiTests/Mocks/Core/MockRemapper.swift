//
//  MockRemapper.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
@testable import HyperCapsLoki

final class MockRemapper: RemapExecutor {
  var remappingCapsLockKeyReceived: Key?
  var resetUserKeyMappingCapsLockCalled = false
  
  func remapUserKeyMappingCapsLock(using key: Key) {
    remappingCapsLockKeyReceived = key
  }
  
  func resetUserKeyMappingCapsLock() {
    resetUserKeyMappingCapsLockCalled = true
  }
}

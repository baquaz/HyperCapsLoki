//
//  MockRemapper.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
@testable import HyperCapsLoki

struct MockRemapper: RemapExecutor {
  func remapUserKeyMappingCapsLock(using key: Key) { }
  func resetUserKeyMappingCapsLock() { }
}

//
//  MockRemapKeyUseCase.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 04/05/2025.
//

import Foundation
@testable import HyperCapsLoki

final class MockRemapKeyUseCase: RemapKeyUseCase {
  private(set) var receivedExecuteNewKey: Key?
  
  func execute(newKey: Key?) {
    receivedExecuteNewKey = newKey
  }
}

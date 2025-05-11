//
//  MockLoginItemHandler.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

final class MockLoginItemHandler: AppLoginItemService {
  var checkStatusCalled = false
  var isEnabled: Bool = false
  var shouldThrowOnRegister: Bool = false
  var shouldThrowOnUnregister: Bool = false
  
  private(set) var didRegister: Bool = false
  private(set) var didUnregister: Bool = false
    
  func checkStatus() -> Bool {
    checkStatusCalled = true
    return isEnabled
  }
  
  func register() throws {
    if shouldThrowOnRegister {
      throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock register error"])
    }
    didRegister = true
  }
  
  func unregister() throws {
    if shouldThrowOnUnregister {
      throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock unregister error"])
    }
    didUnregister = true
  }
}

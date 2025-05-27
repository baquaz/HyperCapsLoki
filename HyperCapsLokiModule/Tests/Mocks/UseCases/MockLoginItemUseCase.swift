//
//  MockLoginItemUseCase.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 04/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

final class MockLoginItemUseCase: LoginItemUseCase {
  var loginItemEnabledState = false
  var checkLoginItemEnabledStatusCalled: Bool = false

  var shouldThrowError: Bool = false

  private(set) var receivedSaveIsEnabled: Bool?
  private(set) var receivedSetLoginItemState: Bool?

  func checkLoginItemEnabledStatus() -> Bool {
    checkLoginItemEnabledStatusCalled = true
    return loginItemEnabledState
  }

  func saveState(_ isEnabled: Bool) {
    receivedSaveIsEnabled = isEnabled
  }

  func setLoginItem(_ isEnabled: Bool) throws {
    if shouldThrowError {
      throw NSError(
        domain: "MockError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Mock register error"]
      )
    }
    receivedSetLoginItemState = isEnabled
  }
}

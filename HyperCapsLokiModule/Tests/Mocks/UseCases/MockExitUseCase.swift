//
//  MockExitUseCase.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 04/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

final class MockExitUseCase: ExitUseCase {
  var terminateCalled = false
  var exitCalled = false

  func terminate() {
    terminateCalled = true
  }

  func exit() {
    exitCalled = true
  }
}

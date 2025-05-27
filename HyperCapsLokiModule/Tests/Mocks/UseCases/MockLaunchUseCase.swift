//
//  MockLaunchUseCase.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 04/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

final class MockLaunchUseCase: LaunchUseCase {
  private(set) var launchCalled = false

  func launch() {
    launchCalled = true
  }
}

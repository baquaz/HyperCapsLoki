//
//  MockRuntimeManager.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

final class MockRuntimeManager: RuntimeProtocol {
  weak var appState: AppState?
  
  private(set) var didCallStart = false
  private(set) var didCallExit = false
  
  var onStart: (() -> Void)?
  var onExit: (() -> Void)?
  
  func start() {
    didCallStart = true
    onStart?()
  }
  
  func exit() {
    didCallExit = true
    onExit?()
  }
}

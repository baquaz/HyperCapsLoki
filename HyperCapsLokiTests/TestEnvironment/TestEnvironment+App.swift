//
//  TestEnvironment+App.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 08/05/2025.
//

import Foundation
@testable import HyperCapsLoki

// MARK: - App
extension TestEnvironment {
  
  @discardableResult
  func makeAppState(_ appState: AppState = .init()) -> Self {
    var copy = self
    copy.appState = appState
    return copy
  }
  
  @MainActor
  @discardableResult
  func makeAppDelegate(
    _ appDelegate: AppDelegate? = nil,
    shouldAutoWireRuntime: Bool = false,
    runtimeOverride: RuntimeProtocol? = nil
  ) -> Self {
    var copy = self
    copy.appDelegate = appDelegate ?? AppDelegate()
    
    if shouldAutoWireRuntime {
      copy.appDelegate.makeRuntimeManager = { appState in
        copy.runTimeManager.appState = appState
        return copy.runTimeManager
      }
    }
    
    if let runtimeOverride {
      copy.appDelegate.runtimeManager = runtimeOverride
    }
    
    return copy
  }
  
}

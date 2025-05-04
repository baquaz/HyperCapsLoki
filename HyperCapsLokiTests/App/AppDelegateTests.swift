//
//  AppDelegateTests.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
import Testing
import AppKit
@testable import HyperCapsLoki

extension AppTests {
  
  @Suite("App Delegate Tests")
  struct AppDelegateTests {
    
    @MainActor
    @Test("App Delegate receives App State and makes Runtime Manager started")
    func appDelegateReceivesAppStateAndStartsRuntimeManager() async throws {
      let testEnv = TestEnvironment()
        .makeAppState()
        .makeRuntimeManager()
        .makeAppDelegate(shouldAutoWireRuntime: true)
      
      let sut = testEnv.appDelegate!
      // simulate injecting App State, similar as App injects state into AppDelegate
      sut.inject(appState: testEnv.appState)
      
      let runtimeExpectation = AsyncExpectation()
      testEnv.mockRuntimeManager
        .onStart = {
          Task { await runtimeExpectation.fulfill() }
        }
      
      // Act
      sut.applicationDidFinishLaunching(
        Notification(name: NSApplication.didFinishLaunchingNotification)
      )
      
      await runtimeExpectation.wait()
      
      // Assert
      #expect(sut.appState === testEnv.appState)
      #expect(testEnv.runTimeManager.appState === testEnv.appState)
      #expect(testEnv.mockRuntimeManager.didCallStart)
    }
    
    @MainActor
    @Test("App Delegate calls exit on termination")
    func appDelegateCallsExitOnTermination() async throws {
      let testEnv = TestEnvironment()
        .makeRuntimeManager()
      
      let sut = testEnv
        .makeAppDelegate(runtimeOverride: testEnv.runTimeManager)
        .appDelegate!
      
      let runtimeExpectation = AsyncExpectation()
      testEnv.mockRuntimeManager
        .onExit = {
          Task { await runtimeExpectation.fulfill() }
        }
      
      // Act
      let _ = sut.applicationShouldTerminate(NSApplication.shared)
      
      await runtimeExpectation.wait()
      
      // Assert
      #expect(testEnv.mockRuntimeManager.didCallExit)
    }
  }
  
}

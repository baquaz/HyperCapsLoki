//
//  TestEnvironmentBuilder.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation

@testable import HyperCapsLoki

struct TestEnvironment {
  // MARK: App
  var appState: AppState!
  var appDelegate: AppDelegate!
  
  // MARK: Core
  var mockEventsHandler: MockEventsHandler!
  var systemEventsInjector: SystemEventsInjection!
  var mockSystemEventsInjector: MockSystemEventsInjector {
    systemEventsInjector as! MockSystemEventsInjector
  }
  
  var capsLockTriggerTimer: AsyncTimer!
  var mockCapsLockTriggerTimer: MockAsyncTimer {
    capsLockTriggerTimer as! MockAsyncTimer
  }
  
  var remapper: RemapExecutor!
  var mockRemapper: MockRemapper {
    remapper as! MockRemapper
  }
  
  var runTimeManager: RuntimeProtocol!
  var mockRuntimeManager: MockRuntimeManager {
    runTimeManager as! MockRuntimeManager
  }
  
  // MARK: Data
  var storage: StorageProtocol!
  
  // MARK: Domain
  var storageRepository: StorageRepository!
  
  // MARK: Use Cases
  // FIXME: remove Preview Use Cases
  var permissionUseCase: AccessibilityPermissionUseCase!
  var launchUseCase: LaunchUseCase!
  var remapKeyUseCase: RemapKeyUseCase!
  var hyperkeyFeatureUseCase: HyperkeyFeatureUseCase!
  var exitUseCase: ExitUseCase!
}

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

// MARK: - Data
extension TestEnvironment {
  
  @discardableResult
  func makeStorage(_ storage: StorageProtocol = MockStorage()) -> Self {
    var copy = self
    copy.storage = storage
    return copy
  }
}

// MARK: - Core
extension TestEnvironment {
  
  @MainActor
  @discardableResult
  func makeEventsHandler(_ eventsHandler: MockEventsHandler? = nil)
  -> Self {
    var copy = self
    if let eventsHandler {
      copy.mockEventsHandler = eventsHandler
    } else {
      copy.mockEventsHandler = MockEventsHandler(
        systemEventsInjector: systemEventsInjector ?? MockSystemEventsInjector(),
        capsLockTriggerTimer: capsLockTriggerTimer ?? MockAsyncTimer()
      )
    }
    return copy
  }
  
  @discardableResult
  func makeSystemEventsInjector(
    _ systemEventsInjector: SystemEventsInjection = MockSystemEventsInjector()
  ) -> Self {
    var copy = self
    copy.systemEventsInjector = systemEventsInjector
    return copy
  }
  
  @discardableResult
  func makeCapsLockTriggerTimer(_ capsLockTriggerTimer: AsyncTimer = MockAsyncTimer())
  -> Self {
    var copy = self
    copy.capsLockTriggerTimer = capsLockTriggerTimer
    return copy
  }
  
  func makeRemapper(_ remaper: RemapExecutor = MockRemapper()) -> Self {
    var copy = self
    copy.remapper = remaper
    return copy
  }
  
  @MainActor
  @discardableResult
  func makeRuntimeManager(
    _ runtimeManager: RuntimeProtocol? = nil
  ) -> Self {
    var copy = self
    copy.runTimeManager = runtimeManager ?? MockRuntimeManager()
    return copy
  }
  
}

// MARK: - Domain
extension TestEnvironment {
  
  @MainActor
  @discardableResult
  func makeStorageRepository(_ storageRepository: StorageRepository? = nil)
  -> Self {
    var copy = self
    copy.storageRepository = storageRepository ?? StorageRepositoryImpl(
      dataSource: copy.storage)
    return copy
  }
}

//
//  TestEnvironment+App.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 08/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

// MARK: - App
extension TestEnvironment {
  
  @MainActor
  @discardableResult
  func withAppState(
    _ appState: AppState = .init(),
    autoCreateAppEnvironment: Bool = false
  ) -> Self {
    var copy = self
    copy.appState = appState
    
    if autoCreateAppEnvironment {
      copy.appState.container = DIContainer(
        environment:
          MockAppEnvironment(
            remapper: remapper ?? MockRemapper(),
            eventsHandler: mockEventsHandler ?? MockEventsHandler(
              systemEventsInjector: systemEventsInjector ?? MockSystemEventsInjector(),
              capsLockTriggerTimer: capsLockTriggerTimer ?? MockAsyncTimer()
            ),
            storageRepository: storageRepository ?? StorageRepositoryImpl(
              dataSource: storage ?? MockStorage()
            ),
            loginItemUseCase: loginItemUseCase ?? MockLoginItemUseCase(),
            permissionUseCase: permissionUseCase ?? MockPermissionUseCase(),
            launchUseCase: launchUseCase ?? MockLaunchUseCase(),
            remapKeyUseCase: remapKeyUseCase ?? MockRemapKeyUseCase(),
            hyperkeyFeatureUseCase: hyperkeyFeatureUseCase ?? MockHyperkeyFeatureUseCase(),
            exitUseCase: exitUseCase ?? MockExitUseCase()
          )
      )
    }
    
    return copy
  }
  
  @MainActor
  @discardableResult
  func withAppDelegate(
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

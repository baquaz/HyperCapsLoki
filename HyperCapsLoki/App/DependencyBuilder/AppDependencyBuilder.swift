//
//  DependencyBuilder.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation

@MainActor
protocol DepenedencyBuilder {
  func build() -> DIContainer
}

struct AppDependencyBuilder: DepenedencyBuilder {
  func build() -> DIContainer {
    // MARK: Core
    let remapper = Remapper()
    let eventsHandler = EventsHandler(
      systemEventsInjector: SystemEventsInjector(),
      capsLockTriggerTimer: DefaultAsyncTimer()
    )
    
    // MARK: Repositories
    let storageRepo = StorageRepositoryImpl(dataSource: Storage())
    
    // MARK: Use Cases
    let permissionUseCase = AccessibilityPermissionUseCaseImpl(
      permissionService: AccessibilityPermissionHandler()
    )
    
    let launchUseCase = LaunchUseCaseImpl(
      remapper: remapper,
      eventsHandler: eventsHandler,
      storageRepository: storageRepo
    )
    
    let remapKeyUseCase = RemapKeyUseCaseImpl(
      storageRepo: storageRepo,
      eventsHandler: eventsHandler,
      remapper: remapper
    )
    
    let hyperkeyFeatureUseCase = HyperkeyFeatureUseCaseImpl(
      storageRepository: storageRepo,
      eventsHandler: eventsHandler,
      remapper: remapper
    )
    
    let exitUseCase = ExitUseCaseImpl(
      remapper: remapper,
      eventsHandler: eventsHandler
    )
    
    // MARK: Environment
    let environment = AppEnvironment(
      remapper: remapper,
      eventsHandler: eventsHandler,
      storageRepository: storageRepo,
      permissionUseCase: permissionUseCase,
      launchUseCase: launchUseCase,
      remapKeyUseCase: remapKeyUseCase,
      hyperkeyFeatureUseCase: hyperkeyFeatureUseCase,
      exitUseCase: exitUseCase
    )
    
    return DIContainer(environment: environment)
  }
}

//
//  DependencyBuilder.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation

@MainActor
public protocol DepenedencyBuilder {
  func build() -> DIContainer
}

public struct AppDependencyBuilder: DepenedencyBuilder {
  public init() { }

  public func build() -> DIContainer {
    // MARK: - Core
    let loginItemHandler = AppLoginItemHandler()
    let remapper = Remapper()
    let eventsHandler = EventsHandler(
      systemEventsInjector: SystemEventsInjector(),
      capsLockTriggerTimer: DefaultAsyncTimer()
    )

    // MARK: - Repositories
    let storageRepo = StorageRepositoryImpl(dataSource: Storage())

    // MARK: - Use Cases
    let loginItemUseCase = LoginItemUseCaseImpl(
      loginItemHandler: loginItemHandler,
      storageRepository: storageRepo
    )

    let permissionUseCase = AccessibilityPermissionUseCaseImpl(
      permissionService: AccessibilityPermissionHandler()
    )

    let launchUseCase = LaunchUseCaseImpl(
      loginItemHandler: loginItemHandler,
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

    let logsUseCase = LogsUseCaseImpl()

    let exitUseCase = ExitUseCaseImpl(
      remapper: remapper,
      eventsHandler: eventsHandler
    )

    // MARK: - Environment
    let environment = AppEnvironment(
      remapper: remapper,
      eventsHandler: eventsHandler,
      storageRepository: storageRepo,
      loginItemUseCase: loginItemUseCase,
      permissionUseCase: permissionUseCase,
      launchUseCase: launchUseCase,
      remapKeyUseCase: remapKeyUseCase,
      hyperkeyFeatureUseCase: hyperkeyFeatureUseCase,
      logsUseCase: logsUseCase,
      exitUseCase: exitUseCase
    )

    return DIContainer(environment: environment)
  }
}

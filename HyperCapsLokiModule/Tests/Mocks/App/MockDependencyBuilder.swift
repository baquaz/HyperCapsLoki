//
//  MockDependencyBuilder.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

final class MockDependencyBuilder: DepenedencyBuilder {
  func build() -> DIContainer {
    DIContainer(
      environment: MockAppEnvironment(
        remapper: MockRemapper(),
        eventsHandler: MockEventsHandler(
          systemEventsInjector: MockSystemEventsInjector(),
          capsLockTriggerTimer: MockAsyncTimer()
        ),
        storageRepository: StorageRepositoryImpl(dataSource: MockStorage()),
        loginItemUseCase: MockLoginItemUseCase(),
        permissionUseCase: MockPermissionUseCase(),
        launchUseCase: MockLaunchUseCase(),
        remapKeyUseCase: MockRemapKeyUseCase(),
        hyperkeyFeatureUseCase: MockHyperkeyFeatureUseCase(),
        logsUseCase: MockLogsUseCase(),
        exitUseCase: MockExitUseCase()
      )
    )
  }
}

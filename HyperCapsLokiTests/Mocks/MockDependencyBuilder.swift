//
//  MockDependencyBuilder.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
@testable import HyperCapsLoki

final class MockDependencyBuilder: DepenedencyBuilder {
  func build() -> HyperCapsLoki.DIContainer {
    DIContainer(
      environment: MockAppEnvironment(
        remapper: MockRemapper(),
        eventsHandler: MockEventsHandler(
          systemEventsInjector: MockSystemEventsInjector(),
          capsLockTriggerTimer: MockAsyncTimer()
        ),
        storageRepository: PreviewStorage(),
        permissionUseCase: PreviewUseCase(),
        launchUseCase: PreviewUseCase(),
        remapKeyUseCase: PreviewUseCase(),
        hyperkeyFeatureUseCase: PreviewUseCase(),
        exitUseCase: PreviewUseCase()
      )
    )
  }
}

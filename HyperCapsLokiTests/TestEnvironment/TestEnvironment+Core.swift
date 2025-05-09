//
//  TestEnvironment+Core.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 08/05/2025.
//

import Foundation
@testable import HyperCapsLoki

// MARK: - Core
extension TestEnvironment {
  
  @discardableResult
  func makeLoginItemHandler(
    _ loginItemHandler: AppLoginItemService = MockLoginItemHandler()
  ) -> Self {
    var copy = self
    copy.loginItemHandler = loginItemHandler
    return copy
  }
  
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

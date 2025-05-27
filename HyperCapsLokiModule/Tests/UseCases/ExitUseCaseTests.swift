//
//  ExitUseCaseTests.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
import Testing
@testable import HyperCapsLokiModule

extension UseCasesTests {

  @Suite("Exit Use Case Tests")
  struct ExitUseCaseTests {

    @MainActor
    @Test("Exit resets user key mapping CapsLock and disables EventTap handler")
    func exitResetsUserKeyMappingAndDisablesEventTapHandler() async throws {
      let testEnv = TestEnvironment()
        .withRemapper()
        .withEventsHandler()

      let sut = ExitUseCaseImpl(
        remapper: testEnv.remapper,
        eventsHandler: testEnv.mockEventsHandler
      )

      sut.exit()

      #expect(testEnv.mockRemapper.resetUserKeyMappingCapsLockCalled)
    }

  }

}

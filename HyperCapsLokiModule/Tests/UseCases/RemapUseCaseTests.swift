//
//  RemapUseCaseTests.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 03/05/2025.
//

import Foundation
import Testing
@testable import HyperCapsLokiModule

extension UseCasesTests {

  @Suite("Remap Use Case Tests")
  struct RemapUseCaseTests {

    @MainActor
    @Test(
      "Execute sets new key into Events handler and saves in storage",
      arguments: [Key.f19, nil]
    )
    func executeSetsNewKey(_ key: Key?) async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withEventsHandler()
        .withRemapper()

      let sut = RemapKeyUseCaseImpl(
        storageRepo: testEnv.storageRepository,
        eventsHandler: testEnv.mockEventsHandler,
        remapper: testEnv.mockRemapper
      )

      // Act
      sut.execute(newKey: key)

      // Assert
      #expect(testEnv.mockEventsHandler.receivedHyperkey == key)
      #expect(sut.storageRepo.dataSource.selectedHyperkey == key?.rawValue)
    }

    @MainActor
    @Test(
      "Execute CapsLock remaps key or resets remapping, for Hyperkey feature state",
      arguments:
        [Key.f20, nil],
      [true, false]
    )
    func executeRemappingOrReset(key: Key?, isHyperkeyFeatureActive: Bool) async throws {
      let mockStorage = MockStorage(isHyperkeyFeatureActive: isHyperkeyFeatureActive)

      let testEnv = TestEnvironment()
        .withStorage(mockStorage)
        .withStorageRepository()
        .withEventsHandler()
        .withRemapper()

      let sut = RemapKeyUseCaseImpl(
        storageRepo: testEnv.storageRepository,
        eventsHandler: testEnv.mockEventsHandler,
        remapper: testEnv.mockRemapper
      )

      // Act
      sut.execute(newKey: key)

      // Assert
      if isHyperkeyFeatureActive {
        #expect(testEnv.mockRemapper.receivedRemappingCapsLockKey == key)
        #expect(testEnv.mockRemapper.resetUserKeyMappingCapsLockCalled == (key == nil))
      } else {
        #expect(testEnv.mockRemapper.receivedRemappingCapsLockKey == nil)
        #expect(testEnv.mockRemapper.resetUserKeyMappingCapsLockCalled == false)
      }
    }

  }
}

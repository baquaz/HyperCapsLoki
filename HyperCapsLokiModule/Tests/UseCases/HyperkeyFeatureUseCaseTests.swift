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
  
  @Suite("Hyperkey Feature Use Case Tests")
  struct HyperkeyFeatureUseCaseTests { }
}

extension UseCasesTests.HyperkeyFeatureUseCaseTests {
  
  @Suite("Setting Hyperkey Feature State Tests")
  struct SettingHyperkeyFeatureStateTests {
    
    @MainActor
    @Test(
      "withs remapping for active state and selected key",
      arguments:
        [true, false],
      [Key.f11, nil]
    )
    func remaps(
      _ isActive: Bool,
      selectedKey: Key?
    ) async throws {
      let mockStorage = MockStorage(selectedHyperkey: selectedKey?.rawValue)
      let testEnv = TestEnvironment()
        .withEventsHandler()
        .withStorage(mockStorage)
        .withStorageRepository()
        .withRemapper()
      let stubbed = false
      
      let sut = HyperkeyFeatureUseCaseImpl(
        storageRepository: testEnv.storageRepository,
        eventsHandler: testEnv.mockEventsHandler,
        remapper: testEnv.mockRemapper
      )
      
      sut.setHyperkeyFeature(active: isActive, forced: stubbed)
      
      // When active, remaps selected key
      #expect(
        testEnv.mockRemapper.receivedRemappingCapsLockKey ==
        ((isActive && selectedKey != nil) ? selectedKey : nil)
      )
    }
    
    @MainActor
    @Test(
      "Resets remapping",
      arguments: [true, false], // isActive
      [true, false] // isCurrentFeatureStateActive
    )
    func settingHyperkeyFeatureActiveResets(
      isActive: Bool,
      isCurrentFeatureStateActive: Bool
    ) async throws {
      let stubbed = false
      
      let mockStorage = MockStorage(
        isHyperkeyFeatureActive: isCurrentFeatureStateActive
      )
      
      let testEnv = TestEnvironment()
        .withStorage(mockStorage)
        .withStorageRepository()
        .withEventsHandler()
        .withRemapper()
      
      let sut = HyperkeyFeatureUseCaseImpl(
        storageRepository: testEnv.storageRepository,
        eventsHandler: testEnv.mockEventsHandler,
        remapper: testEnv.mockRemapper
      )
      
      sut.setHyperkeyFeature(active: isActive, forced: stubbed)
      
      #expect(
        testEnv.mockRemapper.resetUserKeyMappingCapsLockCalled ==
        (!isActive && isCurrentFeatureStateActive)
      )
    }
    
    @MainActor
    @Test(
      "Forcing overrides feature state",
      arguments:
        [true, false], // isForced
      [true, false] // isActive
    )
    func settingHyperKeyFeatureActiveWithForce(
      _ forced: Bool,
      _ isActive: Bool
    ) async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withEventsHandler()
        .withRemapper()
      
      let sut = HyperkeyFeatureUseCaseImpl(
        storageRepository: testEnv.storageRepository,
        eventsHandler: testEnv.mockEventsHandler,
        remapper: testEnv.mockRemapper
      )
      
      // Act
      sut.setHyperkeyFeature(active: isActive, forced: forced)
      
      // Assert
      
      // Forced saves feature state (simulates user actions).
      //
      // Otherwise simulates permission timer behavior, which periodically
      // handles availability of the feature, preserving current state.
      //
      #expect(
        sut.storageRepository.dataSource.isHyperkeyFeatureActive ==
        (forced ? isActive : nil)
      )
    }
    
  }
}

extension UseCasesTests.HyperkeyFeatureUseCaseTests {
  
  @Suite("Hyperkey Sequence Keys Tests")
  struct HyperkeySequenceKeysTests {
    
    @MainActor
    @Test(
      "Getting  Enabled Sequence Keys Tests",
      arguments:
        [
          [Key.leftCommand],
          [Key.leftCommand, .leftControl],
          [Key.leftCommand, .leftControl, .leftShift],
          [Key.leftCommand, .leftControl, .leftOption, .leftShift],
          []
        ]
    )
    func getEnabledSequenceKeys(_ expectedKeys: [Key]) async throws {
      let stubbed: Bool? = nil
      var mockStorage = MockStorage()
      
      mockStorage.commandKeyInSequence
      = expectedKeys.contains(.leftCommand) ? true : stubbed
      
      mockStorage.controlKeyInSequence =
      expectedKeys.contains(.leftControl) ? true : stubbed
      
      mockStorage.optionKeyInSequence =
      expectedKeys.contains(.leftOption) ? true : stubbed
      
      mockStorage.shiftKeyInSequence =
      expectedKeys.contains(.leftShift) ? true : stubbed
      
      let testEnv = TestEnvironment()
        .withStorage(mockStorage)
        .withStorageRepository()
        .withEventsHandler()
        .withRemapper()
      
      let sut = HyperkeyFeatureUseCaseImpl(
        storageRepository: testEnv.storageRepository,
        eventsHandler: testEnv.mockEventsHandler,
        remapper: testEnv.mockRemapper
      )
      
      // Act
      let result = sut.getHyperkeyEnabledSequenceKeys()
      
      // Assert
      #expect(Set(result) == Set(expectedKeys))
    }
    
    @MainActor
    @Test(
      "Getting Unset Sequence Keys",
      arguments:
        [
          [Key.leftCommand],
          [Key.leftCommand, .leftControl],
          [Key.leftCommand, .leftControl, .leftShift],
          [Key.leftCommand, .leftControl, .leftOption, .leftShift],
          []
        ]
    )
    func getUnsetSequenceKeys(_ expectedKeys: [Key]) async throws {
      let stubbed = false
      var mockStorage = MockStorage()
      
      mockStorage.commandKeyInSequence
      = expectedKeys.contains(.leftCommand) ? nil : stubbed
      
      mockStorage.controlKeyInSequence =
      expectedKeys.contains(.leftControl) ? nil : stubbed
      
      mockStorage.optionKeyInSequence =
      expectedKeys.contains(.leftOption) ? nil : stubbed
      
      mockStorage.shiftKeyInSequence =
      expectedKeys.contains(.leftShift) ? nil : stubbed
      
      let testEnv = TestEnvironment()
        .withStorage(mockStorage)
        .withStorageRepository()
        .withEventsHandler()
        .withRemapper()
      
      let sut = HyperkeyFeatureUseCaseImpl(
        storageRepository: testEnv.storageRepository,
        eventsHandler: testEnv.mockEventsHandler,
        remapper: testEnv.mockRemapper
      )
      
      // Act
      let result = sut.storageRepository.getHyperkeySequenceUnsetKeys()
      
      // Assert
      #expect(Set(result) == Set(expectedKeys))
    }
    
    @MainActor
    @Test(
      "Setting Sequence Key enabled",
      arguments:
        [true, false],
      [Key.leftCommand, .leftControl, .leftOption, .leftShift]
    )
    func setSequenceKey(isEnabled: Bool, expectedKey: Key) async throws {
      
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withEventsHandler()
        .withRemapper()
      
      let sut = HyperkeyFeatureUseCaseImpl(
        storageRepository: testEnv.storageRepository,
        eventsHandler: testEnv.mockEventsHandler,
        remapper: testEnv.mockRemapper
      )
      
      // Act
      sut.setHyperkeySequence(enabled: isEnabled, for: expectedKey)
      
      // Assert
      #expect(sut.storageRepository.dataSource[expectedKey] == isEnabled)
      
      #expect(
        testEnv.mockEventsHandler.receivedAvailableSequenceKeys?
          .contains(expectedKey) == isEnabled
      )
    }
    
    @MainActor
    @Test(
      "Setting All Sequence Key enabled",
      arguments:
        [true, false]
    )
    func setAllSequenceKeys(isEnabled: Bool) async throws {
      
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withEventsHandler()
        .withRemapper()
      
      let sut = HyperkeyFeatureUseCaseImpl(
        storageRepository: testEnv.storageRepository,
        eventsHandler: testEnv.mockEventsHandler,
        remapper: testEnv.mockRemapper
      )
      
      sut.setHyperkeySequenceKeysAll(enabled: isEnabled)
      
      Key.allHyperkeySequenceKeys.forEach { key in
        #expect(sut.storageRepository.dataSource[key] == isEnabled)
      }
    }
    
  }
}

//
//  LaunchUseCaseTests.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 03/05/2025.
//

import Foundation
import Testing
@testable import HyperCapsLoki

extension UseCasesTests {
  
  @Suite("Launch Use Case Tests")
  struct LaunchUseCaseTests { }
}

extension UseCasesTests.LaunchUseCaseTests {
  
  @MainActor
  @Test(
    "Launch sets up event tap handler correctly for hyperkey feature state",
    arguments: [true, false]
  )
  func launchSetsUpEventTapHandlerCorrectly(isHyperkeyFeatureActive: Bool) async throws {
    let mockStorage = MockStorage(isHyperkeyFeatureActive: isHyperkeyFeatureActive)
    
    let testEnv = TestEnvironment()
      .makeRemapper()
      .makeEventsHandler()
      .makeStorage(mockStorage)
      .makeStorageRepository()
    
    let sut = LaunchUseCaseImpl(
      remapper: testEnv.mockRemapper,
      eventsHandler: testEnv.mockEventsHandler,
      storageRepository: testEnv.storageRepository
    )
    
    sut.launch()
    
    #expect(testEnv.mockEventsHandler.setUpEventTapCalled)
    
    // for hyperkey feature inactive, events handler gets disabled
    #expect(testEnv.mockEventsHandler.receivedSetEventTapValue
            == (isHyperkeyFeatureActive ? nil : false))
  }
  
  @MainActor
  @Test(
    "Launch remaps user key mapping CapsLock for selected key and hyperkey feature state",
    arguments: [
      Key.f13,
      nil
    ],
    [
      true,
      false
    ]
  )
  func launchRemapsUserKeyMappingCapsLockForSelectedKey(
    selectedKey: Key?, isHyperkeyFeatureActive: Bool
  ) async throws {
    let mockStorage = MockStorage(
      isHyperkeyFeatureActive: isHyperkeyFeatureActive,
      selectedHyperkey: selectedKey?.rawValue
    )
    
    let testEnv = TestEnvironment()
      .makeRemapper()
      .makeEventsHandler()
      .makeStorage(mockStorage)
      .makeStorageRepository()
    
    let sut = LaunchUseCaseImpl(
      remapper: testEnv.mockRemapper,
      eventsHandler: testEnv.mockEventsHandler,
      storageRepository: testEnv.storageRepository
    )
    
    // Act
    sut.launch()
    
    // Assert
    #expect(testEnv.mockRemapper.receivedRemappingCapsLockKey ==
            (isHyperkeyFeatureActive ? selectedKey : nil)
    )
  }
  
  @MainActor
  @Test(
    "Launch initially enables all unset sequence keys",
    arguments: [
      [Key.leftCommand],
      [Key.leftCommand, .leftControl],
      [Key.leftCommand, .leftControl, .leftOption],
      [Key.leftCommand, .leftControl, .leftOption, .leftShift],
      []
    ]
  )
  func launchInitiallyEnablesAllUnsetSequenceKeys(unsetSequenceKeys: [Key]) async throws {
    var mockStorage = MockStorage()
    let stubbed = false
    
    mockStorage.commandKeyInSequence
    = unsetSequenceKeys.contains(.leftCommand) ? nil : stubbed
    
    mockStorage.controlKeyInSequence =
    unsetSequenceKeys.contains(.leftControl) ? nil : stubbed
    
    mockStorage.optionKeyInSequence =
    unsetSequenceKeys.contains(.leftOption) ? nil : stubbed
    
    mockStorage.shiftKeyInSequence =
    unsetSequenceKeys.contains(.leftShift) ? nil : stubbed
    
    let testEnv = TestEnvironment()
      .makeRemapper()
      .makeEventsHandler()
      .makeStorage(mockStorage)
      .makeStorageRepository()
    
    let sut = LaunchUseCaseImpl(
      remapper: testEnv.mockRemapper,
      eventsHandler: testEnv.mockEventsHandler,
      storageRepository: testEnv.storageRepository
    )
    
    // Act
    sut.launch()
    
    // Assert
    #expect(
      sut.storageRepository.dataSource.commandKeyInSequence ==
      unsetSequenceKeys.contains(.leftCommand)
    )
    #expect(
      sut.storageRepository.dataSource.controlKeyInSequence ==
      unsetSequenceKeys.contains(.leftControl)
    )
    #expect(
      sut.storageRepository.dataSource.optionKeyInSequence ==
      unsetSequenceKeys.contains(.leftOption)
    )
    #expect(
      sut.storageRepository.dataSource.shiftKeyInSequence ==
      unsetSequenceKeys.contains(.leftShift)
    )
  }
  
}

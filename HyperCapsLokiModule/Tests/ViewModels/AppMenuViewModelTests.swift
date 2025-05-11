//
//  AppMenuViewModelTests.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 05/05/2025.
//

import Foundation
import Testing
@testable import HyperCapsLokiModule

extension ViewModelsTests {
  
  @Suite("App Menu View Model Tests")
  struct AppMenuViewModelTests { }
}

extension ViewModelsTests.AppMenuViewModelTests {
  
  @Suite("Initial Setup Tests")
  struct InitialSetupTests {
    
    @MainActor
    @Test("Init sets up dependencies", arguments: [Key.f13])
    func setUpDependencies(_ expectedDefaultHyperkey: Key) async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withLoginItemUseCase()
        .withAccessibiltyPermissionUseCase()
        .withHyperkeyFeatureUseCase()
        .withRemapUseCase()
        .withExitUseCase()
      
      let sut: AppMenuViewModel
      
      // Act
      sut = .init(
        defaultHyperkey: expectedDefaultHyperkey,
        storageRepository: testEnv.storageRepository,
        loginItemUseCase: testEnv.loginItemUseCase,
        permissionUseCase: testEnv.permissionUseCase,
        hyperkeyFeatureUseCase: testEnv.hyperkeyFeatureUseCase,
        remapKeyUseCase: testEnv.remapKeyUseCase,
        exitUseCase: testEnv.exitUseCase
      )
      
      // Assert
      #expect(sut.defaultHyperkey == expectedDefaultHyperkey)
      #expect(sut.hyperkeyFeatureUseCase === testEnv.hyperkeyFeatureUseCase)
      #expect(sut.remapKeyUseCase === testEnv.remapKeyUseCase)
      #expect(sut.exitUseCase === testEnv.exitUseCase)
    }
    
    @MainActor
    @Test(
      "Init sets up Hyperkey Sequence Keys: all, enabled from storage",
      arguments:
        [
          [Key.leftCommand, .leftControl],
          [Key.leftCommand, .leftControl, .f1 ], // f1 not sequence key
          [],
        ]
    )
    func setUpHyperkeySequenceKeys(
      expectedEnabledKeys: [Key]
    ) async throws {
      let stubbed = Key.f1
      
      let expectedAllKeys = Key.allHyperkeySequenceKeys
      
      var mockStorage = MockStorage()
      expectedEnabledKeys.forEach { mockStorage[$0] = true }
      
      let testEnv = TestEnvironment()
        .withStorage(mockStorage)
        .withStorageRepository()
        .withLoginItemUseCase()
        .withAccessibiltyPermissionUseCase()
        .withHyperkeyFeatureUseCase()
        .withRemapUseCase()
        .withExitUseCase()
      
      let sut: AppMenuViewModel
      
      // Act
      sut = .init(
        defaultHyperkey: stubbed,
        storageRepository: testEnv.storageRepository,
        loginItemUseCase: testEnv.loginItemUseCase,
        permissionUseCase: testEnv.permissionUseCase,
        hyperkeyFeatureUseCase: testEnv.hyperkeyFeatureUseCase,
        remapKeyUseCase: testEnv.remapKeyUseCase,
        exitUseCase: testEnv.exitUseCase
      )
      
      // Assert
      #expect(sut.allHyperkeySequenceKeys == expectedAllKeys)
      #expect(
        sut.hyperkeyEnabledSequenceKeys ==
        expectedEnabledKeys.filter { sut.allHyperkeySequenceKeys.contains($0) }
      )
    }
    
    @MainActor
    @Test(
      "Init sets up Hyperkey Feature Active from storage or by default true",
      arguments: [nil, true, false]
    )
    func setUpHyperkeyFeatureActive(_ storageValue: Bool?) async throws {
      let stubbed = Key.f2
      
      let mockStorage = MockStorage(isHyperkeyFeatureActive: storageValue)
      
      let testEnv = TestEnvironment()
        .withStorage(mockStorage)
        .withStorageRepository()
        .withLoginItemUseCase()
        .withAccessibiltyPermissionUseCase()
        .withHyperkeyFeatureUseCase()
        .withRemapUseCase()
        .withExitUseCase()
      
      let sut: AppMenuViewModel
      
      // Act
      sut = .init(
        defaultHyperkey: stubbed,
        storageRepository: testEnv.storageRepository,
        loginItemUseCase: testEnv.loginItemUseCase,
        permissionUseCase: testEnv.permissionUseCase,
        hyperkeyFeatureUseCase: testEnv.hyperkeyFeatureUseCase,
        remapKeyUseCase: testEnv.remapKeyUseCase,
        exitUseCase: testEnv.exitUseCase
      )
      
      //Assert
      if storageValue == nil {
        #expect(sut.isHyperkeyFeatureActive == true)
      } else {
        #expect(sut.isHyperkeyFeatureActive == storageValue)
      }
    }
    
    @MainActor
    @Test(
      "Init sets up Selected Hyperkey from storage",
      arguments: [Key.f11, nil]
    )
    func setUpSelectedKey(_ expectedSelectedKey: Key?) async throws {
      let stubbed = Key.f3
      
      let mockStorage = MockStorage(
        selectedHyperkey: expectedSelectedKey?.rawValue
      )
      
      let testEnv = TestEnvironment()
        .withStorage(mockStorage)
        .withStorageRepository()
        .withLoginItemUseCase()
        .withAccessibiltyPermissionUseCase()
        .withHyperkeyFeatureUseCase()
        .withRemapUseCase()
        .withExitUseCase()
      
      let sut: AppMenuViewModel
      
      // Act
      sut = .init(
        defaultHyperkey: stubbed,
        storageRepository: testEnv.storageRepository,
        loginItemUseCase: testEnv.loginItemUseCase,
        permissionUseCase: testEnv.permissionUseCase,
        hyperkeyFeatureUseCase: testEnv.hyperkeyFeatureUseCase,
        remapKeyUseCase: testEnv.remapKeyUseCase,
        exitUseCase: testEnv.exitUseCase
      )
      
      //Assert
      #expect(sut.selectedKey == expectedSelectedKey)
    }
  }
}

extension ViewModelsTests.AppMenuViewModelTests {
  
  @Suite("Sequence Items Tests")
  struct SequenceItemsTests {
    
    @MainActor
    @Test(
      "Check: Is Sequence Key Enabled When Hyperkey Feature Is Active",
      arguments:
        [
          // key to check,  enabled sequence keys,           expected
          (Key.leftOption,  [Key.leftOption, .leftCommand],  true),
          (.leftControl,    [.leftOption, .leftCommand],     false),
          (.f3,             [.leftOption, .leftCommand],     false),
          (.leftCommand,    [.leftCommand],                  true),
          (.f3,             [.leftCommand],                  false)
        ]
    )
    func checkIsSequenceEnabled(
      for key: Key, enabledSequenceKeys: [Key], expected: Bool
    ) async throws {
      let mockStorage = MockStorage(isHyperkeyFeatureActive: true)
      
      let testEnv = TestEnvironment()
        .withStorage(mockStorage)
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      testEnv.appMenuViewModel.hyperkeyEnabledSequenceKeys = enabledSequenceKeys
      
      let sut = testEnv.appMenuViewModel!
      
      // Act
      let result = sut.isSequenceEnabled(for: key)

      // Assert
      #expect(result == expected)
    }
    
    @MainActor
    @Test("Check: Sequence Disabled When Hyperkey Feature Is Disabled")
    func checkSequenceDisabled() async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      testEnv.appMenuViewModel.hyperkeyEnabledSequenceKeys = [.leftCommand]
      // simulate feature disabled
      testEnv.appMenuViewModel.isHyperkeyFeatureActive = false
      
      let sut = testEnv.appMenuViewModel!
      
      // Act
      let result = sut.isSequenceEnabled(for: .leftCommand)
      
      // Assert
      #expect(result == false)
    }
    
    @MainActor
    @Test(
      "Setting Hyperkey Sequence Key Enabled/Disabled Status",
      arguments: [
        // enabled, key to check,    enabled sequence keys,
        (true,      Key.leftOption,  [Key.leftOption, .leftCommand]),
        (false,     .leftOption,     [.leftOption, .leftCommand]),
        (true,      .leftOption,     [.leftCommand]),
        (false,     .leftOption,     [.leftCommand])
      ]
    )
    func setHyperkeySequence(
      enabled: Bool,
      for key: Key,
      enabledSequenceKeys: [Key],
    ) async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      testEnv.appMenuViewModel.hyperkeyEnabledSequenceKeys = enabledSequenceKeys
      
      let sut = testEnv.appMenuViewModel!
      
      // Act
      sut.setHyperkeySequence(enabled: enabled, for: key)
      
      // Assert
      #expect(sut.hyperkeyEnabledSequenceKeys.contains(key) == enabled)
      #expect(testEnv.mockHyperkeyFeatureUseCase.receivedHyperkeySequenceKey?
        .key == key
      )
      #expect(testEnv.mockHyperkeyFeatureUseCase.receivedHyperkeySequenceKey?
        .enabled == enabled
      )
    }
  }
}

extension ViewModelsTests.AppMenuViewModelTests {
  
  @Suite("Text Tests")
  struct TextTests {
    
    @MainActor
    @Test(
      "Getting Correct Text For Key",
      arguments:
        [
          (Key.f20,                                         "f20"),
          (TestEnvironment.defaultAppMenuViewModelHyperkey, "f1 (default)"),
          (.menuKeyboard,                                   "menu keyboard"),
          (nil,                                             "- no key -")
        ]
    )
    func getTextForKey(for key: Key?, expected: String) async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      let sut = testEnv.appMenuViewModel!
      
      let result = sut.getTextForKey(key)
      
      #expect(result == expected)
    }
  }
}

extension ViewModelsTests.AppMenuViewModelTests {
  
  @Suite("Actions Tests")
  struct ActionsTests {
    // TODO: all Actions tests
    
    @MainActor
    @Test("Open Accessibility Permission Settings Triggers Use Case")
    func openPermissionSettingsTriggersUseCase() async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      let sut = testEnv.appMenuViewModel!
      
      sut.openAccessibilityPermissionSettings()
      
      #expect(testEnv.mockPermissionUseCase.openAccessibilityPermissionSettingsCalled)
    }
    
    @MainActor
    @Test(
      "Successful Setting Login Item State Updates View Model",
      arguments: [true, false]
    )
    func successfulSettingLoginItemState(_ expectedState: Bool) async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      let sut = testEnv.appMenuViewModel!
      
      sut.setLoginItem(expectedState)
      
      #expect(sut.isOpenAtLoginEnabled == expectedState)
    }
    
    @MainActor
    @Test(
      "Setting Login Item State Triggers Use Case",
      arguments: [true, false]
    )
    func settingLoginItemTriggersUseCase(state: Bool) async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      let sut = testEnv.appMenuViewModel!
      
      sut.setLoginItem(state)
      
      #expect(testEnv.mockLoginItemUseCase.receivedSetLoginItemIsEnabled == state)
    }
    
    @MainActor
    @Test("Failed Setting Login Item ON Does Not Update View Model")
    func failedSettingLoginItemOn() async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      testEnv.mockLoginItemUseCase.shouldThrowError = true
      
      let sut = testEnv.appMenuViewModel!
      sut.isOpenAtLoginEnabled = false
      
      sut.setLoginItem(true)
      
      #expect(sut.isOpenAtLoginEnabled == false)
    }

    @MainActor
    @Test("Failed Setting Login Item OFF Does Not Update View Model")
    func failedSettingLoginItemOff() async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      testEnv.mockLoginItemUseCase.shouldThrowError = true
      
      let sut = testEnv.appMenuViewModel!
      sut.isOpenAtLoginEnabled = true
      
      // Act
      sut.setLoginItem(false)
      
      // Assert
      #expect(sut.isOpenAtLoginEnabled == true)
    }
    
    @MainActor
    @Test(
      "Setting Active Status",
      arguments: [true, false]
    )
    func setActiveStatus(_ expected: Bool) async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      let sut = testEnv.appMenuViewModel!
      
      sut.setActiveStatus(expected)
      
      #expect(sut.isHyperkeyFeatureActive == expected)
      #expect(testEnv.mockHyperkeyFeatureUseCase.receivedHyperkeyFeatureStatus?.isActive == expected)
      #expect(testEnv.mockHyperkeyFeatureUseCase.receivedHyperkeyFeatureStatus?.forced == true)
    }
    
    @MainActor
    @Test(
      "Selecting Hyperkey",
      arguments: [Key.f2, nil]
    )
    func selectHyperkey(expected: Key?) async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      let sut = testEnv.appMenuViewModel!
      
      sut.onSelectKey(expected)
      
      #expect(sut.selectedKey == expected)
      #expect(testEnv.mockRemapUseCase.receivedExecuteNewKey == expected)
    }
    
    @MainActor
    @Test("Reset Remapping To Default")
    func resetRemappingToDefault() async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      let sut = testEnv.appMenuViewModel!
      let expected = TestEnvironment.defaultAppMenuViewModelHyperkey
      
      // Act
      sut.resetRemappingToDefault()
      
      // Assert
      #expect(sut.selectedKey == expected)
      #expect(testEnv.mockRemapUseCase.receivedExecuteNewKey == expected)
    }
    
    @MainActor
    @Test("Reset All Enables Hyperkey Feature Status")
    func resetAllToEnableHyperkeyFeature() async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      let sut = testEnv.appMenuViewModel!
      let expected = true
      
      // Act
      sut.resetAll()
      
      // Assert
      #expect(sut.isHyperkeyFeatureActive == expected)
      #expect(testEnv.mockHyperkeyFeatureUseCase.receivedHyperkeyFeatureStatus?
        .isActive == expected
      )
      #expect(testEnv.mockHyperkeyFeatureUseCase.receivedHyperkeyFeatureStatus?
        .forced == true
      )
    }
    
    @MainActor
    @Test(
      "Reset All Clears Selected Key",
      arguments: [Key.f1, .f2, nil]
    )
    func resetAllToClearSelectedKey(_ currentSelectedKey: Key?) async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      let sut = testEnv.appMenuViewModel!
      sut.selectedKey = currentSelectedKey // simulate current selected key
      
      let expected: Key? = nil
      
      sut.resetAll()
      
      #expect(sut.selectedKey == expected)
      #expect(testEnv.mockRemapUseCase.receivedExecuteNewKey == expected)
    }

    @MainActor
    @Test(
      "Reset All Enables All Hyperkey Sequence Keys",
      arguments: [
        [Key.leftCommand, .leftControl, .leftOption, .leftShift]
      ]
    )
    func resetAllEnablesAllHyperkeySequenceKeys(_ expectedEnabledKeys: [Key]) async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      testEnv.mockHyperkeyFeatureUseCase.enabledSequenceKeys = expectedEnabledKeys
      
      let sut = testEnv.appMenuViewModel!
      
      // Act
      sut.resetAll()
      
      // Assert
      #expect(sut.hyperkeyEnabledSequenceKeys == expectedEnabledKeys)
      
      #expect(testEnv.mockHyperkeyFeatureUseCase
        .receivedHyperkeySequenceKeysAll == true)
    }
    
    @MainActor
    @Test(
      "Reset All Sets Login Item OFF"
    )
    func resetAllSetsLoginItemOff() async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      let sut = testEnv.appMenuViewModel!
      sut.isOpenAtLoginEnabled = true
      
      sut.resetAll()
      
      #expect(sut.isOpenAtLoginEnabled == false)
      #expect(testEnv.mockLoginItemUseCase.receivedSetLoginItemIsEnabled == false)
    }
    
    @MainActor
    @Test("Quit")
    func quit() async throws {
      let testEnv = TestEnvironment()
        .withStorage()
        .withStorageRepository()
        .withAppMenuViewModel(autoCreateUseCases: true)
      
      let sut = testEnv.appMenuViewModel!
      
      sut.quit()
      
      #expect(testEnv.mockExitUseCase.terminateCalled)
    }
  }
}

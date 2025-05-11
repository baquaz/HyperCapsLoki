//
//  RuntimeManagerTests.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 10/05/2025.
//

import Foundation
import Testing
@testable import HyperCapsLokiModule

extension CoreTests {
  
  @Suite("Runtime Manager Tests")
  struct RuntimeManagerTests {
    
    @MainActor
    @Test(
      "Start Cheks Login Item Status And Saves It",
      arguments: [true, false]
    )
    func startChecksAndSavesLoginItemStatus(_ expectedStatus: Bool) async throws {
      let testEnv = TestEnvironment()
        .withLoginItemUseCase()
        .withAppState(autoCreateAppEnvironment: true)
      
      testEnv.mockLoginItemUseCase.loginItemEnabledState = expectedStatus
      
      let sut = RuntimeManager(appState: testEnv.appState)
      
      // Act
      sut.start()
      
      // Assert
      #expect(testEnv.mockLoginItemUseCase.checkLoginItemEnabledStatusCalled)
      #expect(testEnv.mockLoginItemUseCase.receivedSaveIsEnabled == expectedStatus)
    }
    
    @MainActor
    @Test(
      "Start Checks Accessibility Permission Status And Updates App State",
      .timeLimit(.minutes(1)),
      arguments: [true, false]
    )
    func startCheckAccessibilityPermissionStatusAndUpdatesAppStatus(
      _ expectedStatus: Bool
    ) async throws {
      
      let testEnv = TestEnvironment()
        .withAccessibiltyPermissionUseCase()
        .withAppState(autoCreateAppEnvironment: true)
      
      testEnv.mockPermissionUseCase.isGranted = expectedStatus

      let sut = RuntimeManager(appState: testEnv.appState)
      
      // Act
      sut.start()
      
      // Assert
      #expect(testEnv.mockPermissionUseCase.receivedCompletion != nil)
      #expect(testEnv.mockPermissionUseCase.ensureAccessibilityPermissionsCalled)
      #expect(sut.appState?.accessibilityPermissionGranted == expectedStatus)
    }

    @MainActor
    @Test("Start Handles Monitoring Permission Setup Completion")
    func startCheckAccessibilityPermissionStatusAndUpdatesAppStatus() async throws {
      let testEnv = TestEnvironment()
        .withAccessibiltyPermissionUseCase()
        .withAppState(autoCreateAppEnvironment: true)
      let sut = RuntimeManager(appState: testEnv.appState)
      
      sut.start()
      
      #expect(testEnv.mockPermissionUseCase.receivedCompletion != nil)
    }
    
    @MainActor
    @Test("On Monitoring Permission Switching To Granted - Triggers Launch", .timeLimit(.minutes(1)))
    func monitoringPermissionSwitchingToGranted() async throws {
      let mockPermissionService = MockAccessibilityPermissionService()
      
      let permissionUseCase = AccessibilityPermissionUseCaseImpl(
        permissionService: mockPermissionService
      )
      let testEnv = TestEnvironment()
        .withLaunchUseCase()
        .withAccessibilityPermissionService(mockPermissionService)
        .withAccessibiltyPermissionUseCase(permissionUseCase)
        .withAppState(autoCreateAppEnvironment: true)
      
      let sut = RuntimeManager(appState: testEnv.appState)
      // initial state switching from
      sut.appState!.accessibilityPermissionGranted = false
      
      let expectation = AsyncExpectation()
      sut.onPermissionChangedHandled = {
        Task { await expectation.fulfill() }
      }
      
      sut.setUpMonitoringPermission()
    
      // Act
      mockPermissionService.triggerPermissionChange(granted: true)
        
      await expectation.wait()
            
      #expect(testEnv.mockLaunchUseCase.launchCalled)
    }

    @MainActor
    @Test(
      "On Monitoring Permission: Switching To Revoked - Sets Hyperkey Feature Disabled (Unforced)",
      .timeLimit(.minutes(1))
    )
    func monitoringPermissionSwitchingToRevoked() async throws {
      let mockPermissionService = MockAccessibilityPermissionService()
      let permissionUseCase = AccessibilityPermissionUseCaseImpl(
        permissionService: mockPermissionService
      )
      
      let testEnv = TestEnvironment()
        .withLaunchUseCase()
        .withHyperkeyFeatureUseCase()
        .withAccessibilityPermissionService(mockPermissionService)
        .withAccessibiltyPermissionUseCase(permissionUseCase)
        .withAppState(autoCreateAppEnvironment: true)
      
      let sut = RuntimeManager(appState: testEnv.appState)
      // initial state switching from
      sut.appState!.accessibilityPermissionGranted = true

      let expectation = AsyncExpectation()
      sut.onPermissionChangedHandled = {
        Task { await expectation.fulfill() }
      }
      
      // Act
      sut.setUpMonitoringPermission()
      mockPermissionService.triggerPermissionChange(granted: false)
        
      await expectation.wait()
            
      // Assert
      #expect(
        testEnv.mockHyperkeyFeatureUseCase.receivedHyperkeyFeatureStatus?
          .isActive == false
      )
      #expect(
        testEnv.mockHyperkeyFeatureUseCase.receivedHyperkeyFeatureStatus?
          .forced == false
      )
    }
    
    @MainActor
    @Test(
      "On Monitoring Permission: Switching To The Same Permission Status - Does Nothing",
      .timeLimit(.minutes(1)),
      arguments: [true, false]
    )
    func monitoringPermissionSwitchingToTheSamePermission(_ status: Bool) async throws {
      let mockPermissionService = MockAccessibilityPermissionService()
      let permissionUseCase = AccessibilityPermissionUseCaseImpl(
        permissionService: mockPermissionService
      )
      
      let testEnv = TestEnvironment()
        .withAccessibilityPermissionService(mockPermissionService)
        .withAccessibiltyPermissionUseCase(permissionUseCase)
        .withAppState(autoCreateAppEnvironment: true)
      
      let sut = RuntimeManager(appState: testEnv.appState)
      // initial state switching from
      sut.appState!.accessibilityPermissionGranted = status
      
      let assertion = AsyncAssertion()
      sut.onPermissionChangedHandled = {
        Task { await assertion.markCalled() }
      }
      
      // Act
      sut.setUpMonitoringPermission()
      mockPermissionService.triggerPermissionChange(granted: status)
      
      // Assert
      #expect(await assertion.didNotCall(timeout: 1))
    }
    
  }
}

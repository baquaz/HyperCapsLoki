//
//  LoginItemUseCaseTests.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
import Testing
@testable import HyperCapsLokiModule
 
extension UseCasesTests {
  
  @Suite("Login Item Use Case Tests")
  struct LoginItemUseCaseTests {
    
    @MainActor
    @Test("Saving State In Storage", arguments: [true, false])
    func saveStateInStorage(_ state: Bool) async throws {
      let testEnv = TestEnvironment()
        .withLoginItemHandler()
        .withStorage()
        .withStorageRepository()
      
      let sut = LoginItemUseCaseImpl(
        loginItemHandler: testEnv.loginItemHandler,
        storageRepository: testEnv.storageRepository
      )
      
      sut.saveState(state)
      
      #expect(sut.storageRepository.dataSource.isLoginItemEnabled == state)
    }
    
    @MainActor
    @Test("Check Login Item Enabled Status Uses Login Item Handler Checking Status")
    func checkLoginItemStatus() async throws {
      let testEnv = TestEnvironment()
        .withLoginItemHandler()
        .withStorage()
        .withStorageRepository()
      
      let sut = LoginItemUseCaseImpl(
        loginItemHandler: testEnv.loginItemHandler,
        storageRepository: testEnv.storageRepository
      )
      
      let _ = sut.checkLoginItemEnabledStatus()
      
      #expect(testEnv.mockLoginItemHandler.checkStatusCalled)
    }
    
    @MainActor
    @Test(
      "Setting Login Item ON Does Not Update Storage When Registering Fails"
    )
    func settingLoginItemOnWithErrorThrown() async throws {
      let testEnv = TestEnvironment()
        .withLoginItemHandler()
        .withStorage()
        .withStorageRepository()
      
      testEnv.mockLoginItemHandler.shouldThrowOnRegister = true
      
      let expectedError = NSError(
        domain: "MockError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Mock register error"]
      )
      
      let sut = LoginItemUseCaseImpl(
        loginItemHandler: testEnv.loginItemHandler,
        storageRepository: testEnv.storageRepository
      )
      
      #expect(
        throws: expectedError,
        performing: {
          try sut.setLoginItem(true)
        }
      )
       
      #expect(sut.storageRepository.dataSource.isLoginItemEnabled == nil)
    }
    
    @MainActor
    @Test(
      "Setting Login Item OFF Does Not Update Storage When Unregistering Fails"
    )
    func settingLoginItemOffWithErrorThrown() async throws {
      let testEnv = TestEnvironment()
        .withLoginItemHandler()
        .withStorage()
        .withStorageRepository()
      
      testEnv.mockLoginItemHandler.shouldThrowOnUnregister = true
      
      let expectedError = NSError(
        domain: "MockError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Mock unregister error"]
      )
      
      let sut = LoginItemUseCaseImpl(
        loginItemHandler: testEnv.loginItemHandler,
        storageRepository: testEnv.storageRepository
      )
      
      #expect(
        throws: expectedError,
        performing: {
          try sut.setLoginItem(false)
        }
      )
      
      #expect(sut.storageRepository.dataSource.isLoginItemEnabled == nil)
    }
    
    @MainActor
    @Test(
      "Setting Login Item State Successfully Registers / Unregisters Item",
      arguments: [true, false]
    )
    func settingLoginItemTriggersRegisteringOrUnregistering(
      _ state: Bool
    ) async throws {
      let testEnv = TestEnvironment()
        .withLoginItemHandler()
        .withStorage()
        .withStorageRepository()
      
      let sut = LoginItemUseCaseImpl(
        loginItemHandler: testEnv.loginItemHandler,
        storageRepository: testEnv.storageRepository
      )
      
      // Act
      try sut.setLoginItem(state)
      
      // Assert
      if state == true {
        #expect(testEnv.mockLoginItemHandler.didRegister)
      } else {
        #expect(testEnv.mockLoginItemHandler.didUnregister)
      }
    }
    
  }
}

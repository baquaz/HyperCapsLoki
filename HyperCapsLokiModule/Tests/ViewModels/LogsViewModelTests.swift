//
//  LogsViewModelTests.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 05/05/2025.
//

import Foundation
import Testing
@testable import HyperCapsLokiModule

extension ViewModelsTests {
  
  @Suite("Logs View Model Tests")
  struct LogsViewModelTests {
    
    @MainActor
    @Test("On Save Logs Success - Makes Result Success")
    func savingLogsOnSuccess() async throws {
      let mockURL = URL(fileURLWithPath: "/mock/path2.log")
      let expectedResult = LogSaveResult
        .success(mockURL)
      
      let testEnv = TestEnvironment()
        .withLogsUseCase()
      
      testEnv.mockLogsUseCase.stubbedLogFileURL = mockURL
      
      let sut = LogsViewModel(logsUseCase: testEnv.logsUseCase)
      
      // Act
      sut.saveLogs()
      
      // Assert
      #expect(sut.saveLogsResult?.id == expectedResult.id)
      #expect(sut.saveLogsResult?.isSuccess == true)
    }

    @MainActor
    @Test("On Save Logs Fail - Makes Result Fail")
    func savingLogsOnFail() async throws {
      let mockError = NSError(
        domain: "MockLogsUseCase",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Simulated save logs error"]
      )
      
      let expectedResult = LogSaveResult
        .failure(mockError)
      
      let testEnv = TestEnvironment()
        .withLogsUseCase()
      
      testEnv.mockLogsUseCase.shouldThrowOnSave = true
      testEnv.mockLogsUseCase.saveLogError = mockError
      
      let sut = LogsViewModel(logsUseCase: testEnv.logsUseCase)
      
      // Act
      sut.saveLogs()
      
      // Assert
      #expect(sut.saveLogsResult?.id == expectedResult.id)
      #expect(sut.saveLogsResult?.isSuccess == false)
    }
    
    @MainActor
    @Test(
      "On Show In Finder Saved Logs - Triggers Use Case And Dismisses",
      .timeLimit(.minutes(1))
    )
    func onShowInFinderSavedLogs() async throws {
      let mockURL = URL(fileURLWithPath: "/mock/path2.log")
      
      let testEnv = TestEnvironment()
        .withLogsUseCase()
        .withLogsViewModel()
      
      let sut = testEnv.logsViewModel!
      
      await confirmation("Dismissed") { dismissPerformed in
        sut.onDismiss = {
          dismissPerformed()
        }
        
        // Act
        sut.showInFinderSavedLogs(mockURL)
        
        // Assert
        #expect(testEnv.mockLogsUseCase.showInFinderCalledWith == mockURL)
      }
    }
    
    @MainActor
    @Test("On Dismiss Called", .timeLimit(.minutes(1)))
    func onDismissCalled() async throws {
      let testEnv = TestEnvironment()
        .withLogsUseCase()
        .withLogsViewModel()
      
      let sut = testEnv.logsViewModel!
      
      await confirmation("Dismissed") { dismissPerformed in
        sut.onDismiss = {
          dismissPerformed()
        }
        
        sut.dismiss()
      }
    }

    @MainActor
    @Test("On Reset - Clears Save Logs Result And Disables Confirmation Toast")
    func onResetClearsSaveLogsResultAndDisablesToast() async throws {
      let mockLogSaveResult = LogSaveResult.success(
        URL(fileURLWithPath: "/mock/path3.log")
      )
      let testEnv = TestEnvironment()
        .withLogsUseCase()
        .withLogsViewModel()
      
      let sut = testEnv.logsViewModel!
      sut.saveLogsResult = mockLogSaveResult
      sut.isToastConfirmationVisible = true
      
      // Act
      sut.reset()
      
      // Assert
      #expect(sut.saveLogsResult == nil)
      #expect(sut.isToastConfirmationVisible == false)
    }
    
    @Test("On Copy To Clipboard - Triggers Use Case And Hides Toast After Timeout")
    @MainActor
    func test_copyToClipboard_triggersToastAndHides() async {
      let mockTimer = MockAsyncTimer()
      let testEnv = TestEnvironment()
        .withLogsUseCase()
        .withLogsViewModel()
      
      testEnv.logsViewModel.toastTimer = mockTimer
      
      let sut = testEnv.logsViewModel!
      let path = URL(fileURLWithPath: "/mock/path4.log")
      sut.saveLogsResult = .success(path)
      
      // Act
      sut.copyToClipboardSavedLogsPath()
      
      // Assert: immediately visible
      #expect(sut.isToastConfirmationVisible == true)
      #expect(testEnv.mockLogsUseCase.copyToClipboardCalledWith == path)
      #expect(mockTimer.started)
      
      // Simulate timer expiration
      await mockTimer.simulateExpiration()
      
      // Assert: toast hidden
      #expect(sut.isToastConfirmationVisible == false)
    }
  }
}


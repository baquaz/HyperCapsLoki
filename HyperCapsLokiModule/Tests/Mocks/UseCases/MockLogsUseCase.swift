//
//  MockLogsUseCase.swift
//  HyperCapsLokiModule
//
//  Created by Piotr Błachewicz on 17/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

final class MockLogsUseCase: LogsUseCase {
  var saveLogError: Error?

  private(set) var saveLogsCalled = false
  private(set) var copyToClipboardCalledWith: URL?
  private(set) var showInFinderCalledWith: URL?

  var stubbedLogFileURL: URL = URL(fileURLWithPath: "/tmp/mock-diagnostics.log")
  var shouldThrowOnSave = false

  func saveLogs() throws -> URL {
    saveLogsCalled = true
    if shouldThrowOnSave {
      throw saveLogError!
    }
    return stubbedLogFileURL
  }

  func copyToClipboard(savedLogsPath: URL) {
    copyToClipboardCalledWith = savedLogsPath
  }

  func showInFinderSavedLogs(_ url: URL) {
    showInFinderCalledWith = url
  }
}

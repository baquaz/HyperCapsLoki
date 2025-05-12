//
//  RemapUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation
import AppLogger
import SwiftUI

@MainActor
public protocol LogsUseCase: AnyObject {
  func saveLogs() throws -> URL
  func copyToClipboard(savedLogsPath: URL)
  func showInFinderSavedLogs(_ url: URL)
}

public final class LogsUseCaseImpl: LogsUseCase {
  // MARK: Init
  public init() { }
  
  public func saveLogs() throws -> URL {
    return try AppLogger.saveLogs()
  }
  
  public func showInFinderSavedLogs(_ url: URL) {
    NSWorkspace.shared.activateFileViewerSelecting([url])
  }
  
  public func copyToClipboard(savedLogsPath: URL) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(savedLogsPath.path(), forType: .string)
  }
}

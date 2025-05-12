//
//  File.swift
//  HyperCapsLokiModule
//
//  Created by Piotr Błachewicz on 16/05/2025.
//

import SwiftUI

@Observable
@MainActor
public final class LogsViewModel {
  public var saveLogsResult: LogSaveResult?
  public var isToastConfirmationVisible = false
  
  // MARK: - Toast Timer
  internal var toastTimer: AsyncTimer = DefaultAsyncTimer()
  
  // MARK: Use Cases
  internal let logsUseCase: LogsUseCase
  
  // MARK: On Dismiss
  public var onDismiss: (() -> Void)?
  
  // MARK: - Init
  public init(logsUseCase: LogsUseCase) {
    self.logsUseCase = logsUseCase
    self.onDismiss = onDismiss
  }
  
  public func saveLogs() {
    do {
      let savedFileURL = try logsUseCase.saveLogs()
      saveLogsResult = .success(savedFileURL)
    } catch {
      saveLogsResult = .failure(error)
      Applog.print(tag: .error, context: .application,
                   "Saving logs failed:", error.localizedDescription)
    }
  }
  
  public func showInFinderSavedLogs(_ url: URL) {
    logsUseCase.showInFinderSavedLogs(url)
    dismiss()
  }
  
  public func copyToClipboardSavedLogsPath() {
    guard case .success(let path) = saveLogsResult else { return }
    logsUseCase.copyToClipboard(savedLogsPath: path)
    
    isToastConfirmationVisible = true
    
    toastTimer.start(interval: .seconds(2), repeating: false) { [weak self] in
      self?.isToastConfirmationVisible = false
    }
  }
  
  public func reset() {
    saveLogsResult = nil
    isToastConfirmationVisible = false
  }
  
  public func dismiss() {
    onDismiss?()
  }
}

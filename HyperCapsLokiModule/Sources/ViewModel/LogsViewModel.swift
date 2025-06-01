//
//  File.swift
//  HyperCapsLokiModule
//
//  Created by Piotr Błachewicz on 16/05/2025.
//

import SwiftUI

/// View model responsible for handling log-saving logic and related UI events
/// such as showing confirmation toasts and dismissing the screen.
@Observable
@MainActor
public final class LogsViewModel {
  /// The result of a log-saving operation (success or failure).
  public var saveLogsResult: LogSaveResult?

  /// Controls visibility of a confirmation toast (for clipboard copy).
  public var isToastConfirmationVisible = false

  // MARK: - Toast Timer

  /// Timer used to hide the toast automatically after a delay.
  internal var toastTimer: AsyncTimer = DefaultAsyncTimer()

  // MARK: - Use Cases

  internal let logsUseCase: LogsUseCase

  // MARK: - Events

  /// Called when the view should be dismissed (e.g., after user action).
  public var onDismiss: (() -> Void)?

  // MARK: - Init
  public init(logsUseCase: LogsUseCase) {
    self.logsUseCase = logsUseCase
    self.onDismiss = onDismiss
  }

  /// Attempts to save logs and updates the UI with the result.
  public func saveLogs() {
    do {
      let savedFileURL = try logsUseCase.saveLogs()
      saveLogsResult = .success(savedFileURL)
    } catch {
      saveLogsResult = .failure(error)

      Applog.print(
        tag: .error,
        context: .application,
        "Saving logs failed:",
        error.localizedDescription
      )
    }
  }

  /// Opens the saved logs file in **Finder**, then dismisses the view.
  public func showInFinderSavedLogs(_ url: URL) {
    logsUseCase.showInFinderSavedLogs(url)
    dismiss()
  }

  /// Copies the path of the saved logs file to the clipboard,
  /// and shows a temporary confirmation toast.
  public func copyToClipboardSavedLogsPath() {
    guard case .success(let path) = saveLogsResult else { return }
    logsUseCase.copyToClipboard(savedLogsPath: path)

    isToastConfirmationVisible = true

    toastTimer.start(interval: .seconds(2), repeating: false) { [weak self] in
      self?.isToastConfirmationVisible = false
    }
  }

  /// Resets the state of the view model (e.g., when the view is reopened).
  public func reset() {
    saveLogsResult = nil
    isToastConfirmationVisible = false
  }

  /// Triggers dismissal of the view.
  public func dismiss() {
    onDismiss?()
  }
}

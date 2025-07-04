//
//  LogsWindowPresenter.swift
//  HyperCapsLokiUI
//
//  Created by Piotr Błachewicz on 16/05/2025.
//

import SwiftUI
import AppKit
import HyperCapsLokiModule

@MainActor
final class LogsWindowPresenter {
  private var window: NSWindow?

  func show(using viewModel: LogsViewModel) {
    // Avoid multiple windows
    if window != nil {
      window?.makeKeyAndOrderFront(nil)
      return
    }

    let logsView = LogsResultSheet(vm: viewModel)
    let hosting = NSHostingController(rootView: logsView)

    let windowSize = NSSize(width: 350, height: 220)
    let newWindow = NSWindow(
      contentRect: Utils.centeredRect(for: windowSize),
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false
    )

    newWindow.title = "Logs"
    newWindow.isReleasedWhenClosed = false
    newWindow.contentViewController = hosting
    newWindow.makeKeyAndOrderFront(nil)
    newWindow.level = .floating

    window = newWindow

    viewModel.onDismiss = { [weak self] in
      self?.window?.close()
      self?.window = nil
    }

    // Handle manual close
    NotificationCenter.default.addObserver(
      forName: NSWindow.willCloseNotification,
      object: newWindow,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        self?.window = nil
      }
    }
  }
}

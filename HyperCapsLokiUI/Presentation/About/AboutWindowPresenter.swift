//
//  File.swift
//  HyperCapsLokiUI
//
//  Created by Piotr Błachewicz on 25/05/2025.
//

import AppKit
import SwiftUI

@MainActor
final class AboutWindowPresenter {
  private var window: NSWindow?

  func show() {
    if let existing = window {
      existing.makeKeyAndOrderFront(nil)
      return
    }

    let aboutView = AboutView {
      self.window?.close()
      self.window = nil
    }

    let hosting = NSHostingController(rootView: aboutView)

    let newWindow = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 360, height: 300),
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false
    )

    newWindow.title = "About HyperCapsLoki"
    newWindow.isReleasedWhenClosed = false
    newWindow.contentViewController = hosting
    newWindow.center()
    newWindow.makeKeyAndOrderFront(nil)
    newWindow.level = .floating

    self.window = newWindow

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

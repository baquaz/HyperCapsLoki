//
//  Utils.swift
//  HyperCapsLokiUI
//
//  Created by Piotr Błachewicz on 17/06/2025.
//

import Foundation
import AppKit

struct Utils {

  @MainActor
  public static func centeredRect(for size: NSSize) -> NSRect {
    let windows = NSApp.windows
    let keyWindowScreen = NSApp.keyWindow?.screen
    let fallbackScreen = windows.first { $0.isVisible }?.screen

    let targetScreen = keyWindowScreen ?? fallbackScreen ?? NSScreen.main
    let screenFrame = targetScreen?.visibleFrame ?? .zero

    let x = screenFrame.origin.x + (screenFrame.width - size.width) / 2
    let y = screenFrame.origin.y + (screenFrame.height - size.height) / 2
    return NSRect(x: x, y: y, width: size.width, height: size.height)
  }
}

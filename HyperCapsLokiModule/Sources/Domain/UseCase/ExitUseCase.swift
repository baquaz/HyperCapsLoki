//
//  ExitUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation
import SwiftUI

@MainActor
public protocol ExitUseCase: AnyObject {
  func terminate()
  func exit()
}

public final class ExitUseCaseImpl: ExitUseCase {
  private var remapper: RemapExecutor
  private var eventsHandler: EventsHandler

  // MARK: - Init
  init(remapper: any RemapExecutor, eventsHandler: EventsHandler) {
    self.remapper = remapper
    self.eventsHandler = eventsHandler
  }

  public func terminate() {
    Applog.print(context: .application, "Start quitting...")
    NSApplication.shared.terminate(nil)
  }

  public func exit() {
    Applog.print(
      context: .application,
      "🚪 App Exit:",
      " - reset Caps Lock key mapping",
      " - disable keyboard events handler",
      separator: "\n"
    )
    remapper.resetUserKeyMappingCapsLock()
    eventsHandler.setEventTap(enabled: false)
  }
}

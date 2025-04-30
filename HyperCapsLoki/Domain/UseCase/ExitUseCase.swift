//
//  ExitUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation
import SwiftUI

@MainActor
protocol ExitUseCase {
  func terminate()
  func exit()
}

final class ExitUseCaseImpl: ExitUseCase {
  private var remapper: RemapExecutor
  private var eventsHandler: EventsHandler
  
  // MARK: - Init
  init(remapper: any RemapExecutor, eventsHandler: EventsHandler) {
    self.remapper = remapper
    self.eventsHandler = eventsHandler
  }
  
  func terminate() {
    NSApplication.shared.terminate(nil)
  }
  
  func exit() {
    remapper.resetUserKeyMappingCapsLock()
    eventsHandler.setEventTap(enabled: false)
    print("exit completed!")
  }
}

//
//  ExitUseCase.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

@MainActor
protocol ExitUseCase {
  func exit() async
}

final class ExitUseCaseImpl: ExitUseCase {
  private var remapper: RemapExecutor
  private var eventsHandler: EventsHandler
  
  // MARK: - Init
  init(remapper: any RemapExecutor, eventsHandler: EventsHandler) {
    self.remapper = remapper
    self.eventsHandler = eventsHandler
  }
  
  func exit() {
    remapper.resetUserKeyMapping()
    eventsHandler.disableEventTap()
  }
}

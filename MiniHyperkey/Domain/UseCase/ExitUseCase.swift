//
//  ExitUseCase.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

protocol ExitUseCase {
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
  
  func exit() {
    remapper.resetUserKeyMapping()
    eventsHandler.disableEventTap()
  }
}

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
    NSApplication.shared.terminate(nil)
  }
  
  public func exit() {
    remapper.resetUserKeyMappingCapsLock()
    eventsHandler.setEventTap(enabled: false)
    print("exit completed!")
  }
}

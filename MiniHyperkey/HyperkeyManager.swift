//
//  HyperkeyManager.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 26/01/2025.
//

import Foundation
import Cocoa

struct HyperkeyManager {
  private let keysProvider: KeysProvider
  private let remapper: RemapExecutor
  private let eventsHandler: EventsHandler
  
  // MARK: - Init
  init(keysProvider: KeysProvider = .shared, remapper: RemapExecutor, eventsHandler: EventsHandler) {
    self.keysProvider = keysProvider
    self.remapper = Remapper(keysProvider: keysProvider)
    self.eventsHandler = eventsHandler
  }
  
  @MainActor
  func launch() {
    //TODO: add selection hyper key from UI
    KeyPreferences.selectedHyperkey = KeysProvider.Key.f14.rawValue
    
    setMappings()
    setUpEvents()
  }
  
  func exit() {
    remapper.resetUserKeyMapping()
    eventsHandler.disableEventTap()
  }
  
  private func setMappings() {
    remapper.resetUserKeyMapping()
    remapper.remapUserKeyMappingCapsLock(using: keysProvider.selectedHyperkey)
  }
  
  @MainActor
  private func setUpEvents() {
    eventsHandler.hyperKey = keysProvider.selectedHyperkey
    eventsHandler.setupEventTap()
  }
}

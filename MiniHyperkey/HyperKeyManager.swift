//
//  HyperKeyManager.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 26/01/2025.
//

import Foundation
import Cocoa

struct HyperKeyManager {
  let keysProvider: KeysProvider
  let remapper: RemapExecutor
  let eventsHandler: EventsHandler
  
  // MARK: - Init
  init(keysProvider: KeysProvider = .shared, remapper: RemapExecutor, eventsHandler: EventsHandler) {
    self.keysProvider = keysProvider
    self.remapper = Remapper(keysProvider: keysProvider)
    self.eventsHandler = eventsHandler
  }
  
  @MainActor func launch() {
    setMappings()
    setUpEvents()
  }
  
  func setMappings() {
    // TODO: read config
    
    remapper.resetUserKeyMapping()
    
    // TODO: use config
    remapper.remapUserKeyMappingCapsLock(using: .f14)
  }
  
  @MainActor func setUpEvents() {
    // TODO: use config
    eventsHandler.setupEventTap()
  }
}

//
//  AppEnvironment.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

struct AppEnvironment {
  // Core components
  let remapper: RemapExecutor
  let eventsHandler: EventsHandler
  
  // Repositories
  let keyStorageRepository: KeyStorageRepository
  
  // Use cases
  let launchUseCase: LaunchUseCase
  let exitUseCase: ExitUseCase
  let remapKeyUseCase: RemapKeyUseCase
}

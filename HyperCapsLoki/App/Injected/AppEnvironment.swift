//
//  AppEnvironment.swift
//  HyperCapsLoki
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

// MARK: - Previews
extension AppEnvironment {
  @MainActor
  static let preview = AppEnvironment(
    remapper: PreviewRemapExecutor(),
    eventsHandler: EventsHandler(),
    keyStorageRepository: PreviewKeyStorage(),
    launchUseCase: PreviewUseCase(),
    exitUseCase: PreviewUseCase(),
    remapKeyUseCase: PreviewUseCase()
  )
}

struct PreviewUseCase: RemapKeyUseCase, LaunchUseCase, ExitUseCase {
  func execute(newKey: Key?) {}
  func launch() {}
  func exit() {}
}

struct PreviewRemapExecutor: RemapExecutor {
  func remapUserKeyMappingCapsLock(using key: Key) {}
  func resetUserKeyMappingCapsLock() {}
}

struct PreviewKeyStorage: KeyStorageRepository {
  func getSelectedHyperkey() -> Key? { .f13 }
  func saveSelectedHyperkey(_ key: Key?) {}
}

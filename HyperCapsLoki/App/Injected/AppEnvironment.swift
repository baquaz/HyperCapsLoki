//
//  AppEnvironment.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation
import CoreGraphics

protocol AppEnvironmentProtocol {
  var defaultHyperkey: Key { get }
  
  // MARK: - Remapper
  var remapper: RemapExecutor { get }
  
  // MARK: - Events Handler
  var eventsHandler: EventsHandler { get }
  
  // MARK: - Storage Repo
  var storageRepository: StorageRepository { get }
  
  // MARK: - Use Cases
  var loginItemUseCase: LoginItemUseCase { get }
  var permissionUseCase: AccessibilityPermissionUseCase { get }
  var launchUseCase: LaunchUseCase { get }
  var remapKeyUseCase: RemapKeyUseCase { get }
  var hyperkeyFeatureUseCase: HyperkeyFeatureUseCase { get }
  var exitUseCase: ExitUseCase { get }
}

// MARK: - App Environment
struct AppEnvironment: AppEnvironmentProtocol {
  
  let defaultHyperkey: Key = .f15
  
  // Core components
  let remapper: RemapExecutor
  let eventsHandler: EventsHandler
  
  // Repositories
  let storageRepository: StorageRepository
  
  // Use cases
  let loginItemUseCase: LoginItemUseCase
  let permissionUseCase: AccessibilityPermissionUseCase
  let launchUseCase: LaunchUseCase
  let remapKeyUseCase: RemapKeyUseCase
  let hyperkeyFeatureUseCase: HyperkeyFeatureUseCase
  let exitUseCase: ExitUseCase
}

// MARK: - Previews
extension AppEnvironment {
  @MainActor
  static let preview = AppEnvironment(
    remapper: PreviewRemapExecutor(),
    eventsHandler: PreviewEventsHandler(
      systemEventsInjector: PreviewSystemEventsInjector(),
      capsLockTriggerTimer: PreviewAsyncTimer()
    ),
    storageRepository: PreviewStorage(),
    loginItemUseCase: PreviewUseCase(),
    permissionUseCase: PreviewUseCase(),
    launchUseCase: PreviewUseCase(),
    remapKeyUseCase: PreviewUseCase(),
    hyperkeyFeatureUseCase: PreviewUseCase(),
    exitUseCase: PreviewUseCase()
  )
}

class PreviewEventsHandler: EventsHandler {
  override func setUpEventTap() { }
  override func setEventTap(enabled: Bool) { }
  override func set(_ hyperkey: Key?) { }
  override func set(availableSequenceKeys: [Key]) { }
  override func handleHyperkeyPress(_ type: CGEventType) { }
  override func handleEventTap(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent
  ) -> Unmanaged<CGEvent>? { nil }
}

struct PreviewSystemEventsInjector: SystemEventsInjection {
  var hyperkeyDownSequence: [CGEventFlags] = []
  var hyperkeyUpSequence: [CGEventFlags] = []
  func setUpHyperkeySequenceKeyUp(_ sequence: [CGEventFlags]) {}
  func setUpHyperkeySequenceKeyDown(_ sequence: [CGEventFlags]) {}
  func injectHyperkeyFlagsSequence(isKeyDown: Bool) {}
  func injectCapsLockStateToggle() {}
}

final class PreviewAsyncTimer: AsyncTimer {
  func start(
    interval: Duration,
    repeating: Bool,
    action: @escaping @MainActor @Sendable () -> Void
  ) {}
  
  func cancel() {}
}

class PreviewUseCase:
  LoginItemUseCase,
  AccessibilityPermissionUseCase,
  LaunchUseCase,
  RemapKeyUseCase,
  HyperkeyFeatureUseCase,
  ExitUseCase
{
    
  func checkLoginItemEnabledStatus() -> Bool { false }
  func saveState(_ isEnabled: Bool) { }
  func setLoginItem(_ isEnabled: Bool) throws { }
  func openAccessibilityPermissionSettings() {}
  func ensureAccessibilityPermissionsAreGranted() -> Bool { true }
  func monitorChanges(completion: @escaping (Bool) -> Void) {}
  func stopMonitoring() { }
  func launch() { }
  func execute(newKey: Key?) { }
  func setHyperkeyFeature(active: Bool, forced: Bool) {}
  func getHyperkeyEnabledSequenceKeys() -> [Key] { [] }
  func setHyperkeySequence(enabled: Bool, for key: Key) { }
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool) { }
  func terminate() { }
  func exit() { }
}

struct PreviewRemapExecutor: RemapExecutor {
  func remapUserKeyMappingCapsLock(using key: Key) { }
  func resetUserKeyMappingCapsLock() { }
}

struct PreviewStorage: StorageRepository {
  var dataSource: any StorageProtocol = Storage()
  
  func getLoginItemEnabledState() -> Bool { false }
  func setLoginItemEnabledState(_ isEnabled: Bool) { }
  
  func getHyperkeyFeatureState() -> Bool? { nil }
  func setHyperkeyFeatureState(_ isActive: Bool) {  }

  func getSelectedHyperkey() -> Key? { .f15 }
  func saveSelectedHyperkey(_ key: Key?) { }

  func getHyperkeySequenceUnsetKeys() -> [Key] { [] }
  func getHyperkeyEnabledSequenceKeys() -> [Key] { [] }
  func setHyperkeySequence(enabled isEnabled: Bool, for key: Key) { }
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool) { }
}

//
//  PreviewAppEnvironment.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 10/05/2025.
//

import Foundation
import SwiftUI
import AppKit
import HyperCapsLokiModule

// MARK: - Previews
extension AppEnvironment {
  @MainActor
  public static let preview = AppEnvironment(
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
    logsUseCase: PreviewUseCase(),
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
  func simulateExpiration() async {

  }

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
  LogsUseCase,
  ExitUseCase {

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
  func saveLogs() throws -> URL { URL(string: "http://apple.com")! }
  func copyToClipboard(savedLogsPath: URL) { }
  func showInFinderSavedLogs(_ url: URL) { }
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

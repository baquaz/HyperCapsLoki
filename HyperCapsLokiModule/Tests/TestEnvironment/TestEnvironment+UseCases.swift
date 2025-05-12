//
//  TestEnvironment+UseCases.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 08/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

// MARK: - Use Cases
extension TestEnvironment {
  
  @MainActor
  @discardableResult
  func withLoginItemUseCase(
    _ loginItemUseCase: LoginItemUseCase? = nil
  ) -> Self {
    var copy = self
    copy.loginItemUseCase = loginItemUseCase ?? MockLoginItemUseCase()
    return copy
  }
  
  @MainActor
  @discardableResult
  func withAccessibiltyPermissionUseCase(
    _ permissionUseCase: AccessibilityPermissionUseCase? = nil
  ) -> Self {
    var copy = self
    copy.permissionUseCase = permissionUseCase ?? MockPermissionUseCase()
    return copy
  }
  
  @MainActor
  func withLaunchUseCase(_ launchUseCase: LaunchUseCase? = nil) -> Self {
    var copy = self
    copy.launchUseCase = launchUseCase ?? MockLaunchUseCase()
    return copy
  }
  
  @MainActor
  @discardableResult
  func withHyperkeyFeatureUseCase(
    _ hyperkeyFeatureUseCase: HyperkeyFeatureUseCase? = nil
  ) -> Self {
    var copy = self
    copy.hyperkeyFeatureUseCase = hyperkeyFeatureUseCase ??
    MockHyperkeyFeatureUseCase()
    
    return copy
  }
  
  @MainActor
  @discardableResult
  func withRemapUseCase(_ remapUseCase: RemapKeyUseCase? = nil) -> Self {
    var copy = self
    copy.remapKeyUseCase = remapUseCase ?? MockRemapKeyUseCase()
    return copy
  }
  
  @MainActor
  @discardableResult
  func withLogsUseCase(_ logsUseCase: LogsUseCase? = nil) -> Self {
    var copy = self
    copy.logsUseCase = logsUseCase ?? MockLogsUseCase()
    return copy
  }
  
  @MainActor
  @discardableResult
  func withExitUseCase(_ exitUseCase: ExitUseCase? = nil) -> Self {
    var copy = self
    copy.exitUseCase = exitUseCase ?? MockExitUseCase()
    return copy
  }
  
}

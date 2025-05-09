//
//  TestEnvironment+UseCases.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 08/05/2025.
//

import Foundation
@testable import HyperCapsLoki

// MARK: - Use Cases
extension TestEnvironment {
  
  @MainActor
  @discardableResult
  func makeLoginItemUseCase(
    _ loginItemUseCase: LoginItemUseCase? = nil
  ) -> Self {
    var copy = self
    copy.loginItemUseCase = loginItemUseCase ?? MockLoginItemUseCase()
    return copy
  }
  
  @MainActor
  func makeAccessibiltyPermissionUseCase(
    _ permissionUseCase: AccessibilityPermissionUseCase? = nil
  ) -> Self {
    var copy = self
    copy.permissionUseCase = permissionUseCase ?? MockPermissionUseCase()
    return copy
  }
  
  @MainActor
  @discardableResult
  func makeHyperkeyFeatureUseCase(
    _ hyperkeyFeatureUseCase: HyperkeyFeatureUseCase? = nil
  ) -> Self {
    var copy = self
    copy.hyperkeyFeatureUseCase = hyperkeyFeatureUseCase ??
    MockHyperkeyFeatureUseCase()
    
    return copy
  }
  
  @MainActor
  @discardableResult
  func makeRemapUseCase(_ remapUseCase: RemapKeyUseCase? = nil) -> Self {
    var copy = self
    copy.remapKeyUseCase = remapUseCase ?? MockRemapKeyUseCase()
    return copy
  }
  
  @MainActor
  @discardableResult
  func makeExitUseCase(_ exitUseCase: ExitUseCase? = nil) -> Self {
    var copy = self
    copy.exitUseCase = exitUseCase ?? MockExitUseCase()
    return copy
  }
  
}

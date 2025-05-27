//
//  TestEnvironment+ViewModels.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 08/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule

// MARK: - View Models
extension TestEnvironment {

  static let defaultAppMenuViewModelHyperkey: Key = Key.f1

  @MainActor
  @discardableResult
  func withAppMenuViewModel(
    _ appMenuViewModel: AppMenuViewModel? = nil,
    autoCreateUseCases: Bool = false
  ) -> Self {
    var copy = self

    if autoCreateUseCases {
      copy.loginItemUseCase = MockLoginItemUseCase()
      copy.permissionUseCase = MockPermissionUseCase()
      copy.hyperkeyFeatureUseCase = MockHyperkeyFeatureUseCase()
      copy.remapKeyUseCase = MockRemapKeyUseCase()
      copy.exitUseCase = MockExitUseCase()
    }

    copy.appMenuViewModel = appMenuViewModel ?? AppMenuViewModel(
      defaultHyperkey: TestEnvironment.defaultAppMenuViewModelHyperkey,
      storageRepository: copy.storageRepository,
      loginItemUseCase: copy.loginItemUseCase,
      permissionUseCase: copy.permissionUseCase,
      hyperkeyFeatureUseCase: copy.hyperkeyFeatureUseCase,
      remapKeyUseCase: copy.remapKeyUseCase,
      exitUseCase: copy.exitUseCase
    )
    return copy
  }

  @MainActor
  @discardableResult
  func withLogsViewModel(
    _ logsViewModel: LogsViewModel? = nil,
    autoCreateUseCases: Bool = false
  ) -> Self {
    var copy = self
    if autoCreateUseCases {
      copy.logsUseCase = MockLogsUseCase()
    }

    copy.logsViewModel = logsViewModel ?? LogsViewModel(
      logsUseCase: copy.logsUseCase
    )
    return copy
  }
}

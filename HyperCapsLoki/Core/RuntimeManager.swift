//
//  HyperkeyManager.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 26/01/2025.
//

import Foundation
import Cocoa

@MainActor
final class RuntimeManager {
  
  private let launchUseCase: LaunchUseCase
  private let exitUseCase: ExitUseCase

  init(launchUseCase: any LaunchUseCase, exitUseCase: any ExitUseCase) {
    self.launchUseCase = launchUseCase
    self.exitUseCase = exitUseCase
  }

  func launch() async {
    await launchUseCase.launch()
  }
  
  func exit() async {
    await exitUseCase.exit()
  }
}

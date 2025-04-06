//
//  HyperkeyManager.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 26/01/2025.
//

import Foundation
import Cocoa

final class HyperkeyManager {
  
  private let launchUseCase: LaunchUseCase
  private let exitUseCase: ExitUseCase
  
  init(launchUseCase: any LaunchUseCase, exitUseCase: any ExitUseCase) {
    self.launchUseCase = launchUseCase
    self.exitUseCase = exitUseCase
  }

  @MainActor
  func launch() async {
    await launchUseCase.launch()
  }
  
  func exit() {
    exitUseCase.exit()
  }
}

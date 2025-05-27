//
//  DIContainer.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

public struct DIContainer {
  public var environment: AppEnvironmentProtocol

  public init(environment: AppEnvironmentProtocol) {
    self.environment = environment
  }
}

//
//  AppState.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

@Observable
public final class AppState {
  public var container: DIContainer?
  public var accessibilityPermissionGranted = false
  
  public init() { }
}

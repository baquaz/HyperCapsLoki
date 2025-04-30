//
//  AppState.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

@Observable
final class AppState {
  var container: DIContainer?
  var accessibilityPermissionGranted = false
}

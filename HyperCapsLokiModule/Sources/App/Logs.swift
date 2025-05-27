//
//  Logs.swift
//  HyperCapsLokiModule
//
//  Created by Piotr Błachewicz on 12/05/2025.
//

import AppLogger

typealias Applog = AppLogger

// Logging Contexts
extension DefaultLoggingContext {
  public static let application =
  DefaultLoggingContext(rawValue: "APPLICATION")

  public static let hyperkey =
  DefaultLoggingContext(rawValue: "HYPERKEY_FEATURE")

  public static let permissions =
  DefaultLoggingContext(rawValue: "PERMISSIONS")

  public static let keyRemapping =
  DefaultLoggingContext(rawValue: "REMAPPING")

  public static let keyboardEvents =
  DefaultLoggingContext(rawValue: "KEYBOARD_EVENTS")
}

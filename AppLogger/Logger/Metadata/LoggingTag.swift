//
//  LoggingTag.swift
//  AppLogger
//
//  Created by Piotr Błachewicz on 17/05/2025.
//

import Foundation

// MARK: - Logging Tag
public protocol LoggingTag: Sendable {
  var label: String { get }
}

// MARK: - Default Logging Tag
public enum DefaultLoggingTag: LoggingTag {
  case debug
  case success
  case warning
  case error
  case critical

  public var label: String {
    switch self {
      case .debug:
        "🔵 DEBUG"
      case .success:
        "🟢 SUCCESS"
      case .warning:
        "🟠 WARNING"
      case .error:
        "🔴 ERROR"
      case .critical:
        "🔥 CRITICAL 🔥"
    }
  }
}

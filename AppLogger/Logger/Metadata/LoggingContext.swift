//
//  LoggingContext.swift
//  AppLogger
//
//  Created by Piotr Błachewicz on 17/05/2025.
//

import Foundation

// MARK: - Logging Tag
public protocol LoggingContext: Sendable {
  var label: String { get }
}

public struct DefaultLoggingContext: RawRepresentable, Hashable, Sendable {
  public let rawValue: String

  public var label: String { "<\(rawValue)>" }

  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

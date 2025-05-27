//
//  File.swift
//  AppLogger
//
//  Created by Piotr Błachewicz on 11/05/2025.
//

import Foundation
import os.log

// MARK: - Log Strategy
public protocol LogStrategy: Sendable {
  var defaultLoggingTag: LoggingTag { get set }

  func log(output: String, tag: any LoggingTag, category: String)
}

// MARK: - Log Persisting
public protocol LogPersisting: LogStrategy {
  func persistToFile() throws -> URL
}

// MARK: - Buffered File Log Strategy
public struct BufferedFileLogStrategy: LogStrategy, LogPersisting {
  private static let isoFormat =
  Date.ISO8601FormatStyle()
    .year()
    .month()
    .day()
    .dateTimeSeparator(.space)
    .timeZone(separator: .omitted)
    .time(includingFractionalSeconds: true)

  public var defaultLoggingTag: any LoggingTag = DefaultLoggingTag.debug
  private let logBuffer: LogBuffering

  // MARK: - Init
  init(logBuffer: LogBuffering = DefaultLogBuffer()) {
    self.logBuffer = logBuffer
  }

  public func log(
    output: String,
    tag: any LoggingTag,
    category: String
  ) {
    DispatchQueue.global(qos: .utility).async {
      let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "--", category: category)

      switch tag {
        case let defaultTag as DefaultLoggingTag:
          switch defaultTag {
            case .debug:  logger.debug("\(output)")
            case .success: logger.info("\(output)")
            case .warning: logger.warning("\(output)")
            case .error: logger.fault("\(output)")
            case .critical: logger.critical("\(output)")
          }
        default: logger.log("\(output)")
      }

      // Timestamp
      let timestamp = Date().formatted(Self.isoFormat)

      logBuffer.add("[\(timestamp)] \(output)")
    }
  }

  // MARK: - Save Logs Manually
  public func persistToFile() throws -> URL {
    let logs = logBuffer.dump().joined(separator: "\n\n")
    guard let data = logs.data(using: .utf8) else {
      throw NSError(domain: "AppLogger", code: 1, userInfo: nil)
    }

    let fileURL = try Self.logFileURL()

    // Ensure directory exists
    try FileManager.default.createDirectory(
      at: fileURL.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )

    // Rotate file if size exceeds limit
    if FileManager.default.fileExists(atPath: fileURL.path),
       let attributes =
        try? FileManager.default.attributesOfItem(atPath: fileURL.path),
       let fileSize = attributes[.size] as? UInt64,
       fileSize > logBuffer.maxByteSize {
      try FileManager.default.removeItem(at: fileURL)
    }

    // Write logs to file
    try data.write(to: fileURL, options: .atomic)
    return fileURL
  }

  private static func logFileURL() throws -> URL {
    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    ?? "HyperCapsLoki"

    guard let logsDir = FileManager
      .default
      .urls(for: .libraryDirectory, in: .userDomainMask)
      .first?
      .appendingPathComponent("Logs")
      .appendingPathComponent(appName)
    else {
      throw NSError(
        domain: "AppLogger",
        code: 2,
        userInfo: [
          NSLocalizedDescriptionKey: "Missing location for storing logs"
        ]
      )
    }

    return logsDir.appendingPathComponent("diagnostics.log")
  }
}

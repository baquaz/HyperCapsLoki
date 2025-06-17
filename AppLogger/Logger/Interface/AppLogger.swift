//
//  File.swift
//  AppLogger
//
//  Created by Piotr Błachewicz on 11/05/2025.
//

import Foundation

// MARK: - App Logger
public struct AppLogger: AppLogging {

  private static let engine = LogEngine()

  private static let isLoggerEnabled: Bool = {
    if let env = ProcessInfo.processInfo.environment["ENABLE_APP_LOGGER"]?.lowercased() {
      return env == "true"
    }

#if DEBUG
    Swift.print("[APP_LOGGER ⚠️]: Xcode Environment Variable `ENABLE_APP_LOGGER` is missing, logs are disabled")
    return false
#else
    return true
#endif
  }()

  // MARK: - Set Custom LogStrategy
  public static func setLogStrategy(_ strategy: LogStrategy) {
    engine.setStrategy(strategy)
  }

  // MARK: - Print Default Tagged Message
  public static func print(
    tag: DefaultLoggingTag = .debug,
    context: DefaultLoggingContext? = nil,
    _ items: Any...,
    separator: String = " ",
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    guard isLoggerEnabled else { return }

    // Category
    let category = formatLocationInfo(file: file, function: function, line: line)

    // Context
    let contextLabel: String
    if let context {
      contextLabel = "\(context.label) "
    } else {
      contextLabel = ""
    }

    // Message
    let message = items.map { "\($0)" }.joined(separator: separator)

    // Output
    let output = "\(contextLabel)\(tag.label)\n\(message)"

    engine.log(output: output, tag: tag, category: category)
  }

  // MARK: - Print Custom Tagged Message
  public static func printCustom(
    tag: (any LoggingTag)? = nil,
    context: (any LoggingContext)? = nil,
    _ items: Any...,
    separator: String = " ",
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    guard isLoggerEnabled else { return }

    // Category
    let category = formatLocationInfo(file: file, function: function, line: line)

    // Tag
    let tagLabel = tag?.label ?? ""

    // Context
    let contextLabel: String
    if let context {
      contextLabel = tagLabel.isEmpty ? context.label : " \(context.label)"
    } else {
      contextLabel = ""
    }

    // Message
    let message = items.map { "\($0)" }.joined(separator: separator)

    // Output
    let output = "\(tagLabel)\(contextLabel)\n\(message)"

    engine.log(output: output, tag: tag, category: category)
  }

  // MARK: - Save Logs
  public static func saveLogs() throws -> URL {
    try engine.persistBufferedLogs()
  }

  // MARK: - Format Location Info
  private static func formatLocationInfo(
    file: String, function: String,
    line: Int
  ) -> String {
    "\(file.components(separatedBy: "/").last ?? "---") - \(function) - line \(line)"
  }
}

//
//  LogEngine.swift
//  AppLogger
//
//  Created by Piotr Błachewicz on 12/05/2025.
//

import Foundation

// MARK: - Log Engine
final class LogEngine: @unchecked Sendable {
  private let logQueue = DispatchQueue(
    label: "com.hypercapsloki.logger.queue",
    qos: .utility
  )
  internal var strategy: LogStrategy = BufferedFileLogStrategy()
  
  func log(
    output: String,
    tag: any LoggingTag,
    category: String
  ) {
    logQueue.async { [weak self] in
      self?.strategy.log(
        output: output,
        tag: tag,
        category: category
      )
    }
  }
  
  func log(
    output: String,
    tag: LoggingTag? = nil,
    category: String
  ) {
    let resolvedTag = tag ?? strategy.defaultLoggingTag
    logQueue.async { [weak self] in
      self?.strategy.log(
        output: output,
        tag: resolvedTag,
        category: category
      )
    }
  }
  
  func setStrategy(_ newStrategy: LogStrategy) {
    logQueue.async { [weak self] in
      self?.strategy = newStrategy
    }
  }
}


extension LogEngine {
  public func persistBufferedLogs() throws -> URL {
    guard let fileLogger = strategy as? LogPersisting else {
      throw NSError(domain: "AppLoggerEngine", code: 1, userInfo: nil)
    }
    return try fileLogger.persistToFile()
  }
}

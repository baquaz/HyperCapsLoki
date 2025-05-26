//
//  File.swift
//  AppLogger
//
//  Created by Piotr Błachewicz on 11/05/2025.
//

import Foundation

///
public protocol AppLogging {
  /// Prints pre-defined log
  /// - Parameters:
  ///   - tag: logging tag
  ///   - context: logging context
  ///   - items: list of params to print
  ///   - separator: custom separator for items
  ///   - file: source file of log
  ///   - function: source function of log
  ///   - line: file's line number of log
  /// 
  static func print(
    tag: DefaultLoggingTag,
    context: DefaultLoggingContext?,
    _ items: Any...,
    separator: String,
    file: String,
    function: String,
    line: Int
  )
  
  static func printCustom(
    tag: (any LoggingTag)?,
    context: (any LoggingContext)?,
    _ items: Any...,
    separator: String,
    file: String,
    function: String,
    line: Int
  )
  
  static func saveLogs() async throws -> URL
}

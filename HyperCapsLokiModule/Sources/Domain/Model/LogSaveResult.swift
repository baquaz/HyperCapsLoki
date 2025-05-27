//
//  LogSaveResult.swift
//  HyperCapsLokiModule
//
//  Created by Piotr Błachewicz on 15/05/2025.
//

import Foundation

public enum LogSaveResult: Identifiable {
  case success(URL)
  case failure(Error)

  public var id: String {
    switch self {
      case .success(let url): return "success-\(url.absoluteString)"
      case .failure(let error): return "failure-\(error.localizedDescription)"
    }
  }

  public var isSuccess: Bool {
    if case .success = self { return true }
    return false
  }

  public var url: URL? {
    if case .success(let url) = self { return url }
    return nil
  }

  public var error: Error? {
    if case .failure(let error) = self { return error }
    return nil
  }
}

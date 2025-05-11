//
//  AssetProviding.swift
//  HyperCapsLokiModule
//
//  Created by Piotr Błachewicz on 10/05/2025.
//

import AppKit
import SwiftUI

public protocol AssetProviding {
  // NSImages
  var logo: NSImage { get }
  
  // Colors
  var colorThemeBold: Color { get }
  var colorThemePrimary: Color { get }
  var colorThemeSecondary: Color { get }
  var colorThemeTertiary: Color { get }
}

public final class AppAssetProvider: AssetProviding {
  private let assets: AssetProviding
  
  public init(assets: AssetProviding) {
    self.assets = assets
  }
  
  // Images
  public var logo: NSImage {
    assets.logo
  }
  
  // Colors
  public var colorThemeBold: Color {
    assets.colorThemeBold
  }
  
  public var colorThemePrimary: Color {
    assets.colorThemePrimary
  }
  
  public var colorThemeSecondary: Color {
    assets.colorThemeSecondary
  }
  
  public var colorThemeTertiary: Color {
    assets.colorThemeTertiary
  }
  
}

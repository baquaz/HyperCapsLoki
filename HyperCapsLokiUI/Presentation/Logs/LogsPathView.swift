//
//  LogsPathView.swift
//  HyperCapsLokiUI
//
//  Created by Piotr Błachewicz on 16/05/2025.
//

import SwiftUI

struct LogsPathView: View {
  let text: String
  let maxLines: Int

  var onCopy: (() -> Void)?

  @State private var textHeight: CGFloat = 0

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ScrollView(.vertical) {
        Text(text)
          .font(.system(size: 12, design: .monospaced))
          .textSelection(.enabled)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(6)
          .background(GeometryReader { geometry in
            Color.clear
              .onAppear {
                textHeight = geometry.size.height
              }
          })
      }
      .background(Color(NSColor.textBackgroundColor))
      .cornerRadius(6)
      .overlay(
        RoundedRectangle(cornerRadius: 6)
          .stroke(Color.gray.opacity(0.3))
      )
      .frame(height: min(textHeight, estimatedHeight(for: maxLines)))

      HStack {
        Spacer()
        Button("Copy") {
          onCopy?()
        }
        .font(.caption)
      }
    }
  }

  private func estimatedHeight(for lines: Int) -> CGFloat {
    let lineHeight = NSFont
      .monospacedSystemFont(ofSize: 12, weight: .regular)
      .boundingRectForFont
      .height
    return (lineHeight * CGFloat(lines)) + 12 // padding
  }
}

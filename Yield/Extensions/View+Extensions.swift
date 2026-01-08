//
//  View+Extensions.swift
//  Yield
//
//  Created on 1/8/26.
//

import SwiftUI

extension View {
  /// Apply card-style shadow and corner radius
  func cardStyle(cornerRadius: CGFloat = 20) -> some View {
    self
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
      .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
  }

  /// Apply wallet-style dark background
  func walletBackground() -> some View {
    self
      .background {
        LinearGradient(
          colors: [
            Color(red: 0.05, green: 0.05, blue: 0.08),
            Color(red: 0.08, green: 0.08, blue: 0.12),
          ],
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea()
      }
  }
}

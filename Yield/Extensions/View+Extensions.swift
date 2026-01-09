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
      .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
  }
}

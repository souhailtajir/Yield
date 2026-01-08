//
//  YieldCardView.swift
//  Yield
//
//  Created on 1/8/26.
//

import SwiftUI

/// Apple Card-style view with animated MeshGradient background
struct YieldCardView: View {
  let balance: String
  let yieldPercentage: Double
  let onTap: () -> Void

  @State private var animationPhase: CGFloat = 0

  /// Dynamic colors based on yield percentage
  private var gradientColors: [Color] {
    let intensity = min(max(yieldPercentage * 10, 0), 1)  // Normalize to 0-1

    return [
      // Top row - cooler tones
      Color(red: 0.1, green: 0.1 + intensity * 0.2, blue: 0.2),
      Color(red: 0.15, green: 0.2 + intensity * 0.3, blue: 0.35),
      Color(red: 0.1, green: 0.15 + intensity * 0.2, blue: 0.25),

      // Middle row - transition
      Color(red: 0.2, green: 0.3 + intensity * 0.4, blue: 0.4),
      Color(red: 0.3 + intensity * 0.2, green: 0.5, blue: 0.6),
      Color(red: 0.2, green: 0.4 + intensity * 0.3, blue: 0.5),

      // Bottom row - warmer highlights
      Color(red: 0.25 + intensity * 0.3, green: 0.35, blue: 0.3),
      Color(red: 0.4 + intensity * 0.4, green: 0.5, blue: 0.4),
      Color(red: 0.3 + intensity * 0.3, green: 0.4, blue: 0.35),
    ]
  }

  /// Animated control points for MeshGradient
  private var animatedPoints: [SIMD2<Float>] {
    let phase = Float(animationPhase)
    let wave1 = sin(phase) * 0.03
    let wave2 = cos(phase * 0.7) * 0.03

    return [
      // Row 0
      SIMD2(0.0, 0.0),
      SIMD2(0.5 + wave1, 0.0),
      SIMD2(1.0, 0.0),

      // Row 1
      SIMD2(0.0, 0.5 + wave2),
      SIMD2(0.5 + wave2, 0.5 + wave1),
      SIMD2(1.0, 0.5 - wave2),

      // Row 2
      SIMD2(0.0, 1.0),
      SIMD2(0.5 - wave1, 1.0),
      SIMD2(1.0, 1.0),
    ]
  }

  var body: some View {
    ZStack {
      // Animated MeshGradient background
      MeshGradient(
        width: 3,
        height: 3,
        points: animatedPoints,
        colors: gradientColors
      )

      // Card content overlay
      VStack(alignment: .leading, spacing: 0) {
        // Top section - Logo and chip
        HStack {
          Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
            .font(.system(size: 32, weight: .medium))
            .foregroundStyle(.white.opacity(0.9))

          Spacer()

          // Card chip
          RoundedRectangle(cornerRadius: 4)
            .fill(
              LinearGradient(
                colors: [.yellow.opacity(0.8), .orange.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(width: 40, height: 30)
            .overlay {
              HStack(spacing: 2) {
                ForEach(0..<4, id: \.self) { _ in
                  Rectangle()
                    .fill(.black.opacity(0.3))
                    .frame(width: 1)
                }
              }
            }
        }

        Spacer()

        // Balance section
        VStack(alignment: .leading, spacing: 4) {
          Text("Total Balance")
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.7))

          Text(balance)
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
        }

        Spacer()

        // Bottom section - Yield info
        HStack {
          VStack(alignment: .leading, spacing: 2) {
            Text("YIELD")
              .font(.caption2)
              .fontWeight(.semibold)
              .foregroundStyle(.white.opacity(0.6))

            Text("Yield Portfolio")
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundStyle(.white.opacity(0.9))
          }

          Spacer()

          // APY Badge
          HStack(spacing: 4) {
            Image(systemName: "arrow.up.right")
              .font(.caption)
            Text(yieldPercentage.formatted(.percent.precision(.fractionLength(2))))
              .font(.headline)
              .fontWeight(.bold)
          }
          .foregroundStyle(.white)
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .glassEffect(.regular)
        }
      }
      .padding(24)
    }
    .frame(height: 220)
    .cardStyle(cornerRadius: 20)
    .onTapGesture {
      onTap()
    }
    .onAppear {
      withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
        animationPhase = .pi * 2
      }
    }
  }
}

#Preview {
  YieldCardView(
    balance: "$24,567.89",
    yieldPercentage: 0.0485,
    onTap: {}
  )
  .padding()
  .walletBackground()
}

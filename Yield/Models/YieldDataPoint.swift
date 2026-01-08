//
//  YieldDataPoint.swift
//  Yield
//
//  Created on 1/8/26.
//

import Foundation

/// Data point for yield chart visualization
struct YieldDataPoint: Identifiable, Sendable, Codable {
  let id: UUID
  let date: Date
  let yieldValue: Double

  init(id: UUID = UUID(), date: Date, yieldValue: Double) {
    self.id = id
    self.date = date
    self.yieldValue = yieldValue
  }
}

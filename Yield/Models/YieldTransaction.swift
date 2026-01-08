//
//  YieldTransaction.swift
//  Yield
//
//  Created on 1/8/26.
//

import Foundation
import SwiftData

/// SwiftData model representing a financial transaction
@Model
final class YieldTransaction: @unchecked Sendable {
  var id: UUID
  var title: String
  var amount: Double
  var date: Date
  var categoryRaw: String
  var isCredit: Bool
  var notes: String?

  /// Portfolio relationship (inverse)
  var portfolio: Portfolio?

  /// Computed category from raw string
  var category: TransactionCategory {
    get { TransactionCategory(rawValue: categoryRaw) ?? .other }
    set { categoryRaw = newValue.rawValue }
  }

  init(
    id: UUID = UUID(),
    title: String,
    amount: Double,
    date: Date = .now,
    category: TransactionCategory = .other,
    isCredit: Bool = false,
    notes: String? = nil
  ) {
    self.id = id
    self.title = title
    self.amount = amount
    self.date = date
    self.categoryRaw = category.rawValue
    self.isCredit = isCredit
    self.notes = notes
  }
}

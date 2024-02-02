//
//  Enums.swift
//  Quad
//
//  Created by Macbook on 16/12/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import Cocoa

enum CellIdentifiers {
  static let NameCell = "NameCellID"
  static let PriceCell = "PriceCellID"
  static let HoldingCell = "HoldingCellID"
  static let ListCell = "ListCellID"
  static let BarCell = "BarCellID"

}

enum Currency: String {
  case USD = "USD"
  case GBP = "GBP"
  case EUR = "EUR"
}

enum UpOrDown {
  case up
  case down
  case same
}

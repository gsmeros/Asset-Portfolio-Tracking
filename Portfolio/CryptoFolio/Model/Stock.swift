//
//  Stock.swift
//  CryptoFolio
//
//  Created by Georgios Smeros on 01/02/2024.
//  Copyright © 2024 gsmeros. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyJSON

struct Stock: Codable, Asset {
    
  var image: String? = nil
  
  var priceColor: UpOrDown = .same
  var displayName: String {
    guard let name = self.description, let symbol = self.displaySymbol else {
      return "unknown"
    }
    return "\(name) (\(symbol.uppercased()))"
  }

  var type: String?
  var displaySymbol: String?
  var description: String?
  var currency: String? = "USD"
  var currentPrice: Double?
  
  var colorChange: NSColor {
    var color:NSColor = NSColor.black
    switch self.priceColor {
    case .up:
      color = NSColor.greeny
    case .down:
      color = NSColor.redy
    case .same:
      color = APIManager.shared.barColor
    }
    return color
  }
    
  var price: Double? {
    get {
      guard let current = self.currentPrice else {
        return nil
      }
      if APIManager.shared.currency == .GBP {
        guard let rate = APIManager.shared.GBPRate else {
          return nil
        }
        return rate*current
      } else if APIManager.shared.currency == .EUR {
        guard let rate = APIManager.shared.EURORate else {
          return nil
        }
        return rate*current
      } else {
        return currentPrice
      }
    } set {
      currentPrice = newValue
    }
  }
  
  var lastUpdated: String?
  
  enum CodingKeys: String, CodingKey {
    case currency = "currency"
    case displaySymbol = "displaySymbol"
    case description = "description"
    case type = "type"
  }
}

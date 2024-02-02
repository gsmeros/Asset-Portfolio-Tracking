//
//  Coin.swift
//  Quad
//
//  Created by Macbook on 16/12/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyJSON

struct Coin: Codable, Asset {
    
  var localImage: NSImage? {
    return NSImage.init(named: self.displaySymbol?.lowercased() ?? "Error")
  }
  
  var priceColor: UpOrDown = .same
  var displayName: String {
    guard let name = self.coinName, let symbol = self.displaySymbol else {
      return "Unknwon"
    }
    return "\(name) (\(symbol.uppercased()))"
  }
  var id: String?
  var displaySymbol: String?
  var coinName: String?
  var image: String?
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
    case id = "id"
    case displaySymbol = "symbol"
    case coinName = "name"
    case image = "image"
    case currentPrice = "current_price"
    case lastUpdated = "last_updated"
  }

}

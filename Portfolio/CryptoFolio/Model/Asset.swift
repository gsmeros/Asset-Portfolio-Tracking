//
//  Asset.swift
//  CryptoFolio
//
//  Created by Georgios Smeros on 02/02/2024.
//  Copyright © 2024 gsmeros. All rights reserved.
//

import Foundation
import Cocoa

protocol Asset {
  var displaySymbol: String? {get set}
  var displayName: String {get}
  var holdings: Double? {get}
  var image: String? {get set}
  var inList: Bool {get}
  var inBar: Bool {get}
  
  var price: Double? {get set}
  var colorChange: NSColor {get}
}

extension Asset {
  static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.displaySymbol == rhs.displaySymbol
  }
  
  var value: Double? {
    guard let alias = self.displaySymbol, let price = self.price else {
      return nil
    }
    return UserDefaults.standard.double(forKey: alias)*price
  }
  
  var holdings: Double? {
    guard let alias = self.displaySymbol else {
      return nil
    }
    return UserDefaults.standard.double(forKey: alias)
  }
  
  var inList: Bool {
    if let alias = self.displaySymbol {
      let inL = UserDefaults.standard.bool(forKey: "inList\(alias)")
      return inL
    } else {
      return false
    }
  }
  var inBar: Bool {
    if let alias = self.displaySymbol {
      let inL = UserDefaults.standard.bool(forKey: "inBar\(alias)")
      return inL
    } else {
      return false
    }
  }
}

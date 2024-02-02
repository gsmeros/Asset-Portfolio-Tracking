//
//  CoinManager.swift
//  CryptoFolio
//
//  Created by Macbook on 18/12/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import Cocoa

class CoinManager {
  
  static let shared = CoinManager()

  var coins: [Coin] = []
  var stocks: [Stock] = []

  var assets: [Asset] {
    return coins + stocks
  }
  
  func getListAssets() -> [Asset] {
    let coins = coins.filter({$0.inList})
    let stocks = stocks.filter({$0.inList})
    return coins + stocks
  }
  
  func getBarAssets() -> [Asset] {
    let coins = coins.filter({$0.inBar})
    let stocks = stocks.filter({$0.inBar})
    return coins + stocks
  }
  
  func getAssetsWithHoldings() -> [Asset] {
    let coins = coins.filter({($0.holdings ?? 0) > 0})
    let stocks = stocks.filter({($0.holdings ?? 0) > 0})
    return coins + stocks
  }
  
  func updateCoins(_ coins: [Coin]) {
    for coin in coins {
      if let _ = self.coins.first(where: { $0.id == coin.id }) {
        self.updatePriceFor(newCoin: coin)
      } else {
        self.coins.append(coin)
      }
    }
  }
  
  func updatePriceFor(newStock: Stock) {
    if let existingStock = stocks.first(where: { $0.displaySymbol == newStock.displaySymbol }) {
      var newStock = newStock
      if let previous = existingStock.price, let new = newStock.price {
        if previous > new {
          newStock.priceColor = .down
        } else if previous < new {
          newStock.priceColor = .up
        } else {
          newStock.priceColor = .same
        }
      }
      
      let optionalIndex = stocks.firstIndex(where: { $0.displaySymbol == newStock.displaySymbol })
      guard let index = optionalIndex else {
        return
      }
      
      self.stocks[index] = newStock
    }
  }
  
  func updatePriceFor(newCoin: Coin) {
    if let existingCoin = coins.first(where: { $0.id == newCoin.id }) {
      var newCoin = newCoin
      if let previous = existingCoin.price, let new = newCoin.price {
        if previous > new {
          newCoin.priceColor = .down
        } else if previous < new {
          newCoin.priceColor = .up
        } else {
          newCoin.priceColor = .same
        }
      }
      
      let optionalIndex = coins.firstIndex(where: { $0.id == newCoin.id })
      guard let index = optionalIndex else {
        return
      }
      
      self.coins[index] = newCoin
    }
  }
  
  class func getAll() -> [Asset] {
    return CoinManager.shared.assets
  }
}

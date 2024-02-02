import Foundation
import Cocoa
import Alamofire
import SwiftyJSON

class APIManager {
  static let shared = APIManager()
  var portfolioSum: Double? {
    var sum: Double = 0.0
    for coin in CoinManager.shared.coins {
      let hold = UserDefaults.standard.double(forKey: "\(coin.displaySymbol ?? "Error")")
      let price = coin.price ?? 0.0
      sum = sum + hold*price
    }
    return sum
  }
  
  fileprivate var pollTimer: Timer?
  fileprivate var secondPollTimer: Timer?
  var currency: Currency = .GBP
  var GBPRate: Double?
  var EURORate: Double?
  var barColor: NSColor = .black
  
  func getCoins(completion: ((_ result: Bool) -> Void)? = nil) {
    self.performGetCoins { (result) in
      completion?(result)
    }
  }
  
  func getStocks(completion: ((_ result: Bool) -> Void)? = nil) {
    self.performGetStocks { (result) in
      completion?(result)
    }
  }
  
  func performGetStocks(completion: ((_ result: Bool) -> Void)? = nil) {
    let path = "https://finnhub.io/api/v1/stock/symbol?exchange=US&token=c0ak7tn48v6sc0grjd40"
    self.makeRequestWith(path: path) { (response) in
      guard let response = response, let data = response.data else {
        completion?(false)
        return
      }
      do {
        let decoded = try JSONDecoder().decode([Stock].self, from: data)
        CoinManager.shared.stocks = decoded
        NotificationCenter.default.post(name: NSNotification.Name.init("update"), object: nil)
        print("\(decoded.count) stocks")
        completion?(true)
      } catch {
        print(error.localizedDescription)
        completion?(false)
      }
    }
  }
    
  func performGetCoins(completion: ((_ result: Bool) -> Void)? = nil) {
    let path = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=false"
    self.makeRequestWith(path: path) { (response) in
      guard let response = response, let data = response.data else {
        completion?(false)
        return
      }
      do {
        let decoded = try JSONDecoder().decode([Coin].self, from: data)
        CoinManager.shared.updateCoins(decoded)
        NotificationCenter.default.post(name: NSNotification.Name.init("update"), object: nil)
        print("\(decoded.count) coins")
        completion?(true)
      } catch {
        print(error.localizedDescription)
        completion?(false)
      }
    }
  }
  
  func getCurrencySymbolString() -> String {
    if APIManager.shared.currency == .GBP {
      return "£"
    } else if APIManager.shared.currency == .USD {
      return "$"
    } else {
      return "€"
    }
  }
  
  func getCurrencySymbolCharacter() -> Character {
    if APIManager.shared.currency == .GBP {
      return "£"
    } else if APIManager.shared.currency == .USD {
      return "$"
    } else {
      return "€"
    }
  }
  
  func updateExchangeRates(completion: ((_ result: Bool) -> Void)? = nil) {
    let path = "https://api.freecurrencyapi.com/v1/latest?apikey=fca_live_aU22MQl7WnUprGDVoVthAR9zmHXawEwH2aN9EJst"
    self.makeRequestWith(path: path) { (result) in
      guard let result = result, let response = result.value as? [String: Any] else {
        completion?(false)
        return
      }
      if let rate = response["data"] as? [String: Any] {
        if let GBPrate = rate["GBP"] as? Double {
          self.GBPRate = GBPrate
        }
        if let EURORate = rate["EUR"] as? Double {
          self.EURORate = EURORate
        }
        completion?(true)
      } else {
        completion?(false)
      }
    }
  }
  
  func makeRequestWith(path: String, completion: @escaping (_ result: DataResponse<Any>?) -> Void) {
      guard let url = URL.init(string: path) else {
        completion(nil)
        return
      }
      do {
        let request = try URLRequest.init(url: url, method: .get)
        Alamofire.request(request).responseJSON(completionHandler: { (response) in
          completion(response)
        })
      } catch {
        completion(nil)
        print("error")
      }
  }
  
  func getStockPrices(completion: ((_ result: Bool) -> Void)? = nil) {
    let assetsInList = CoinManager.shared.getListAssets()
    let assetsInBar = CoinManager.shared.getBarAssets()
    let assetsInHoldings = CoinManager.shared.getAssetsWithHoldings()
    
    let assetSet = (assetsInList+assetsInBar+assetsInHoldings)
    
    var uniqueItems: [Asset] = []
    var seenProperties: Set<String> = []

    for item in assetSet {
      if !seenProperties.contains(item.displayName) {
        uniqueItems.append(item)
        seenProperties.insert(item.displayName)
      }
    }
    
    //Now we have a ist of all assets and we filter for stocks
    let uniqueStocks = uniqueItems.filter {$0 as? Stock != nil}
    for item in uniqueStocks {
      guard let symbol = item.displaySymbol else {
        return
      }
        
      let path = "https://finnhub.io/api/v1/quote?symbol=\(symbol)&token=c0ak7tn48v6sc0grjd40"
      self.makeRequestWith(path: path) { (result) in
        guard let result = result, let response = result.value as? [String: Any] else {
          return
        }
        if let currentPrice = response["c"] as? Double, let stock = item as? Stock {
          var updatedStock = stock
          updatedStock.currentPrice = currentPrice
          print("updating \(updatedStock.displayName), price: \(updatedStock.price ?? 0)")
          CoinManager.shared.updatePriceFor(newStock: updatedStock)
        } else {
          //ignore
        }
      }
    }
  }
  
  func start() {
    if pollTimer != nil {
      stopPoll()
    }
    if secondPollTimer != nil {
      stopSecondPoll()
    }
    
    //one time fetch
    self.getStocks { _ in
      self.getStockPrices()
    }

    pollTimer = Timer.scheduledTimer(timeInterval: Double(60), target: self, selector: #selector(doPoll(_:)), userInfo: nil, repeats: true)
    secondPollTimer = Timer.scheduledTimer(timeInterval: Double(600), target: self, selector: #selector(doSecondPoll(_:)), userInfo: nil, repeats: true)
  }
  
  func stopPoll() {
    pollTimer?.invalidate()
    pollTimer = nil
  }
  
  func stopSecondPoll() {
    secondPollTimer?.invalidate()
    secondPollTimer = nil
  }
  
  @objc func doPoll(_ timer: Timer) {
    self.getCoins()
    self.getStockPrices()
  }
  
  @objc func doSecondPoll(_ timer: Timer) {
    self.updateExchangeRates()
  }
}

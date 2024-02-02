import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
  let popover = NSPopover()
  var eventMonitor: EventMonitor?
  let menu = NSMenu()
  let menuItem = NSMenuItem()
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    let interface = InterfaceStyle()
    if interface == .Dark {
      APIManager.shared.barColor = .black
    } else {
      APIManager.shared.barColor = .black
    }
    
    APIManager.shared.updateExchangeRates { (result) in
      APIManager.shared.getCoins { (result) in
        if result {
          APIManager.shared.start()
        } else {
          print("couldn't get coints")
        }
      }
    }

    if let button = statusItem.button {
      self.statusItem.title = "Assetfolio"
      
      NotificationCenter.default.addObserver(forName: NSNotification.Name.init("tick"), object: nil, queue: OperationQueue.main, using: { (notification) in
        self.refresh()
      })
      
      NotificationCenter.default.addObserver(forName: NSNotification.Name.init("update"), object: nil, queue: OperationQueue.main, using: { (notification) in
        self.refresh()
      })
      
      button.action = #selector(AppDelegate.togglePopover(_:))
    }
    
    popover.contentViewController = LivePriceViewController.freshController()
    
    eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
      if let strongSelf = self, strongSelf.popover.isShown {
        strongSelf.closePopover(sender: event)
      }
    }
  }
  
  func refresh() {
    let boldAttrs:[NSAttributedString.Key:Any] = [NSAttributedString.Key.font: NSFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.baselineOffset: NSNumber.init(value: 1)]
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = UserDefaults.standard.integer(forKey: "round")
    formatter.currencySymbol = APIManager.shared.getCurrencySymbolString()
    let string = formatter.string(from: NSNumber.init(value: (APIManager.shared.portfolioSum ?? 0)))
    let extra: NSMutableAttributedString = NSMutableAttributedString.init(string: "")
    for asset in CoinManager.shared.assets {
      if asset.inBar {
        if let price = asset.price {
          let form = NumberFormatter()
          form.maximumFractionDigits = UserDefaults.standard.integer(forKey: "round")
          form.numberStyle = .currency
          form.currencySymbol = APIManager.shared.getCurrencySymbolString()
          let priceNS = NSNumber.init(value: price)
          var priceAsString = form.string(from: priceNS) ?? ""
          priceAsString = " \(priceAsString)"
          priceAsString.append("  ")
          let prefix = getAssetIcon(asset: asset)
          let attString = NSMutableAttributedString.init(string: priceAsString)
          if UserDefaults.standard.bool(forKey: "colors") {
            attString.addAttribute(NSAttributedString.Key.foregroundColor, value: asset.colorChange, range: NSRange(location: 0, length: attString.length))
          }
          prefix.append(attString)
          extra.append(prefix)
        }
      }
    }
    let sumPrefixAttr = NSMutableAttributedString.init(string: "Sum: ", attributes: boldAttrs)
    let sumAmountAttr = NSMutableAttributedString.init(string: string ?? "NA")
    sumPrefixAttr.append(sumAmountAttr)
    sumPrefixAttr.append(NSAttributedString.init(string: " "))
    sumPrefixAttr.append(extra)
    let interface = InterfaceStyle()
    if interface == .Dark {
      sumPrefixAttr.addAttribute(NSAttributedString.Key.foregroundColor, value:  APIManager.shared.barColor, range: NSRange(location: 0, length: sumPrefixAttr.length))
    }
    self.statusItem.attributedTitle = sumPrefixAttr
  }
  
  func getAssetIcon(asset: Asset) -> NSMutableAttributedString {
    let imageAttachment =  NSTextAttachment()
    guard let alias = asset.displaySymbol, alias != "BTC" else {
      imageAttachment.image = NSImage.init(named: "btc")
      let heigh = NSStatusBar.system.thickness/1.3
      let diff = (NSStatusBar.system.thickness - NSStatusBar.system.thickness/1.3)/2.0
      imageAttachment.bounds = CGRect(x: 0, y: -diff, width: heigh, height: heigh)
      return NSMutableAttributedString.init(attributedString: NSAttributedString.init(attachment: imageAttachment))
    }
    
    if let image = NSImage.init(named: asset.displaySymbol?.lowercased() ?? "Error") {
      imageAttachment.image = image
    } else {
      if let icon = asset.image {
        if let url = URL.init(string: icon) {
          imageAttachment.image = NSImage.init(contentsOf: url)
        } else {
          return NSMutableAttributedString.init(string: asset.displaySymbol ?? "NA:")
        }
      } else {
        let string = asset.displaySymbol ?? "NA"
        return NSMutableAttributedString.init(string: ("\(string): "))
      }
    }
    
    let heigh = NSStatusBar.system.thickness/1.3
    let diff = (NSStatusBar.system.thickness - NSStatusBar.system.thickness/1.3)/2.0
    imageAttachment.bounds = CGRect(x: 0, y: -diff, width: heigh, height: heigh)
    return NSMutableAttributedString.init(attributedString: NSAttributedString.init(attachment: imageAttachment))
  }
  
  @objc func togglePopover(_ sender: Any?) {
    if popover.isShown {
      closePopover(sender: sender)
    } else {
      showPopover(sender: sender)
    }
  }
  
  func showPopover(sender: Any?) {
    if let button = statusItem.button {
      popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      eventMonitor?.start()
    }
  }

  func closePopover(sender: Any?) {
    popover.performClose(sender)
    eventMonitor?.stop()
  }
}

import Cocoa
import Kingfisher

class LivePriceViewController: NSViewController,NSTableViewDelegate,NSTableViewDataSource, NSTextFieldDelegate {
  
    var assets: [Asset] = CoinManager.shared.getListAssets()

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    @IBAction func quit(_ sender: Any) {
      NSApplication.shared.terminate(self)
    }
  
  func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
      let sorted = NSMutableArray(array: assets)
      sorted.sort(using: tableView.sortDescriptors)
      assets = sorted as! [Asset]
      tableView.reloadData()
  }

    override func viewWillAppear() {
      super.viewWillAppear()
      self.assets = CoinManager.shared.getListAssets()
      self.tableView.reloadData()
      self.updateContentSize()
    }
  
    func updateContentSize() {
      if self.assets.count > 7 {
        self.preferredContentSize = NSSize.init(width: 400, height: 320)
      } else {
        self.preferredContentSize = NSSize.init(width: 400, height: CGFloat(30*self.assets.count + 115))
      }
    }
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      self.tableView.dataSource = self
      self.tableView.delegate = self
      self.tableView.selectionHighlightStyle = .none
      NotificationCenter.default.addObserver(forName: NSNotification.Name.init("update"), object: nil, queue: OperationQueue.main) { (notification) in
        self.assets = CoinManager.shared.getListAssets()
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.refresh()
        self.updateContentSize()
        self.tableView.reloadData()
      }
      
      NotificationCenter.default.addObserver(forName: NSNotification.Name.init("list"), object: nil, queue: OperationQueue.main) { (notification) in
        self.assets = CoinManager.shared.getListAssets()
        self.tableView.reloadData()
        self.updateContentSize()
      }
    }
}

extension LivePriceViewController {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return self.assets.count
  }
  
  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return 30
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

    var text: String = ""
    var cellIdentifier: String = ""
    
    let item = assets[row]
    
    if tableColumn == tableView.tableColumns[0] {
      text = item.displayName
      cellIdentifier = CellIdentifiers.NameCell
    } else if tableColumn == tableView.tableColumns[1] {
      let form = NumberFormatter()
      form.maximumFractionDigits = 3
      form.numberStyle = .decimal
      text = form.string(from: NSNumber.init(value: item.holdings ?? 0)) ?? ""
      cellIdentifier = CellIdentifiers.HoldingCell
    } else if tableColumn == tableView.tableColumns[2] {
      let form = NumberFormatter()
      form.maximumFractionDigits = UserDefaults.standard.integer(forKey: "round")
      form.numberStyle = .currency
      form.currencySymbol = APIManager.shared.getCurrencySymbolString()
      text = form.string(from: NSNumber.init(value: item.price ?? 0)) ?? ""
      cellIdentifier = CellIdentifiers.PriceCell
    }
    
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
      cell.textField?.delegate = self
      cell.textField?.isBezeled = false
      
      if let image = NSImage.init(named: item.displaySymbol?.lowercased() ?? "Error") {
        cell.imageView?.image = image
      } else {
        if let stringURL = item.image, let url = URL.init(string: stringURL) {
          cell.imageView?.kf.setImage(with: url)
        } else {
          cell.imageView?.image = NSImage.init(named: "crypto")
        }
      }
  
      if cellIdentifier == CellIdentifiers.HoldingCell {
        let form = NumberFormatter()
        form.maximumFractionDigits = 0
        form.numberStyle = .currency
        form.currencySymbol = APIManager.shared.getCurrencySymbolString()
        let rounded = form.string(from: NSNumber.init(value: item.value ?? 0)) ?? ""
        cell.textField?.stringValue = "\(text) (\(rounded))"
      }
      
      return cell
    }
    return nil
  }
}

extension LivePriceViewController {
  // MARK: Storyboard instantiation
  static func freshController() -> LivePriceViewController {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let identifier = "LivePriceViewController"
    guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? LivePriceViewController else {
      fatalError("Why cant i find LivePriceViewController? - Check Main.storyboard")
    }
    return viewcontroller
  }
}

open class MyAspectFillImageNSImageView : NSImageView {
  
  open override var image: NSImage? {
    set {
      self.layer = CALayer()
      self.layer?.contentsGravity = CALayerContentsGravity.resizeAspectFill
      self.layer?.contents = newValue
      self.wantsLayer = true
      
      super.image = newValue
    }
    
    get {
      return super.image
    }
  }
}

class VerticallyAlignedTextFieldCell: NSTextFieldCell {
  override func drawingRect(forBounds rect: NSRect) -> NSRect {
    let newRect = NSRect(x: 0, y: (rect.size.height - 22) / 2, width: rect.size.width, height: 22)
    return super.drawingRect(forBounds: newRect)
  }
}

import Cocoa

class HoldingsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, NSSearchFieldDelegate {
  
  var assets: [Asset] = CoinManager.shared.assets
  var backCoins: [Asset] = CoinManager.shared.assets
  
  @IBOutlet weak var searchField: NSSearchField!
  @IBOutlet weak var tableView: NSTableView!
  
  @IBAction func backPressed(_ sender: Any) {
    self.dismiss(nil)
  }
  
  @IBAction func savePressed(_ sender: Any) {
    
    for i in 0...(self.tableView.numberOfRows-1) {
      if let view = self.tableView.view(atColumn: 1, row: i, makeIfNecessary: false) as? NSTableCellView {
        if let value = view.textField?.stringValue, value.isNumeric, let doubleValue = Double(value) {
          guard let currency = view.objectValue as? String else {
            return
          }          
          UserDefaults.standard.set(doubleValue, forKey: currency)
        }
        self.dismiss(nil)
      }
    }
    
    NotificationCenter.default.post(name: NSNotification.Name.init("update"), object: nil)
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    self.searchField.delegate = self
    self.tableView.selectionHighlightStyle = .none
    self.tableView.delegate = self
    self.tableView.dataSource = self
  }
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return self.assets.count
  }
  
  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return 25
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    
    var text: String = ""
    var cellIdentifier: String = ""
    let item = assets[row]
    
    if tableColumn == tableView.tableColumns[0] {
      text = item.displayName
      cellIdentifier = CellIdentifiers.NameCell
    } else if tableColumn == tableView.tableColumns[1] {
      text = String(item.holdings ?? 0)
      cellIdentifier = CellIdentifiers.HoldingCell
    }
    
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
      cell.textField?.tag = row
      cell.objectValue = item.displaySymbol ?? "Error"
      cell.textField?.textColor = InterfaceStyle() == .Dark ? NSColor.white : NSColor.black
      cell.textField?.delegate = self
      return cell
    }
    
    return nil
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    self.assets = CoinManager.getAll()
    self.searchField.resignFirstResponder()
  }
  
  func dialogOKCancel(question: String, text: String) -> Bool {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    return alert.runModal() == .alertFirstButtonReturn
  }
  
  func controlTextDidChange(_ obj: Notification) {
    if let _ = obj.object as? NSSearchField {
      let searchString = self.searchField.stringValue
      if searchString.isEmpty {
        self.assets = self.backCoins
      }
      else{
        self.assets = self.assets.filter({$0.displayName.uppercased().contains(searchString.uppercased())})
      }
      self.tableView.reloadData()
    }
  }
}



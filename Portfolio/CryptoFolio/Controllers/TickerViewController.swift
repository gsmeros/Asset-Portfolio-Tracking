//
//  TickerViewController.swift
//  Quad
//
//  Created by Macbook on 15/12/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Cocoa

class TickerViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, NSSearchFieldDelegate {
  
  var assets = CoinManager.shared.assets
  var backCoins: [Asset] = CoinManager.shared.assets
  @IBOutlet weak var searchField: NSSearchField!
  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var decimal: NSPopUpButton!
  @IBOutlet weak var segment: NSSegmentedControl!
  @IBOutlet weak var colors: NSButton!

  @IBAction func back(_ sender: Any) {
    self.dismiss(self)
  }
  
  @IBAction func decimalPressed(_ sender: Any) {
    guard let selectedItem = self.decimal.selectedItem else {
      return
    }
    let first = String.init(selectedItem.title.first ?? "0")
    UserDefaults.standard.set(first, forKey: "round")
  }
  
  @IBAction func segmentAction(_ sender: Any) {
    if self.segment.selectedSegment == 0 {
      APIManager.shared.currency = .GBP
    } else if self.segment.selectedSegment == 1 {
      APIManager.shared.currency = .USD
    } else {
      APIManager.shared.currency = .EUR
    }
  }
  
  @IBAction func colorsPressed(_ sender: Any) {
    let value = self.colors.state.rawValue
    let number = NSNumber.init(value: value)
    let bool = Bool.init(exactly: number)
    UserDefaults.standard.set(bool, forKey: "colors")
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    self.searchField.resignFirstResponder()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.decimal.selectItem(withTag: UserDefaults.standard.integer(forKey: "round"))
    if APIManager.shared.currency == .GBP {
      self.segment.setSelected(true, forSegment: 0)
    } else if APIManager.shared.currency == .USD {
      self.segment.setSelected(true, forSegment: 1)
    } else {
      self.segment.setSelected(true, forSegment: 2)
    }
    
    self.colors.state = NSControl.StateValue.init(rawValue: NSNumber.init(value: UserDefaults.standard.bool(forKey: "colors")).intValue)
    
    self.tableView.selectionHighlightStyle = .none
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.searchField.delegate = self
  }
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return self.assets.count
  }
  
  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return 25
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    
    var cellIdentifier: String = ""

    let item = assets[row]
    
    if tableColumn == tableView.tableColumns[0] {
      cellIdentifier = CellIdentifiers.NameCell
      if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        cell.textField?.stringValue = item.displayName
        cell.textField?.textColor = InterfaceStyle() == .Dark ? NSColor.white : NSColor.black
        return cell
      }
    } else if tableColumn == tableView.tableColumns[1] {
      cellIdentifier = CellIdentifiers.ListCell
      if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? ListCell {
        cell.inList.tag = row
        cell.inList.attributedTitle = NSAttributedString.init(string: item.displaySymbol ?? "Error", attributes: [NSAttributedString.Key.foregroundColor: NSColor.clear])

        if item.inList {
          cell.inList.state = NSControl.StateValue.init(rawValue: 1)
        } else {
          cell.inList.state = NSControl.StateValue.init(rawValue: 0)
        }
        return cell
      }
    } else if tableColumn == tableView.tableColumns[2] {
      cellIdentifier = CellIdentifiers.BarCell
      if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? BarCell {
        cell.barCheck.tag = row
        cell.barCheck.attributedTitle = NSAttributedString.init(string: item.displaySymbol ?? "Error", attributes: [NSAttributedString.Key.foregroundColor: NSColor.clear])
        if item.inBar {
          cell.barCheck.state = NSControl.StateValue.init(rawValue: 1)
        } else {
          cell.barCheck.state = NSControl.StateValue.init(rawValue: 0)
        }
        return cell
      }
    }
    return nil
  }
  
  func controlTextDidChange(_ obj: Notification) {
    if let _ = obj.object as? NSSearchField {
      let searchString = self.searchField.stringValue
      if searchString.isEmpty {
        self.assets = self.backCoins
      }
      else{
        self.assets = self.backCoins.filter({$0.displayName.uppercased().contains(searchString.uppercased())})
      }
      self.tableView.reloadData()
    }
  }

}

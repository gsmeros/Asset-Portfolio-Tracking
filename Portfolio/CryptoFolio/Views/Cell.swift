//
//  Cell.swift
//  Quad
//
//  Created by Macbook on 15/12/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Cocoa

class ListCell: NSTableCellView {
  
  override func awakeFromNib() {
  }
  
  @IBOutlet weak var inList: NSButton!
  @IBAction func inListPressed(_ sender: Any) {
    let index = self.inList.attributedTitle.string
    let value = self.inList.state.rawValue
    let number = NSNumber.init(value: value)
    
    UserDefaults.standard.set(Bool.init(exactly: number), forKey: "inList\(index)")
    NotificationCenter.default.post(name: NSNotification.Name.init("list"), object: nil)
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }
}
class BarCell: NSTableCellView {
  
  override func awakeFromNib() {
  }
  
  @IBOutlet weak var barCheck: NSButton!

  @IBAction func inBarPressed(_ sender: Any) {
    let index = self.barCheck.attributedTitle.string
    let value = self.barCheck.state.rawValue
    let number = NSNumber.init(value: value)
    
    UserDefaults.standard.set(Bool.init(exactly: number), forKey: "inBar\(index)")
    NotificationCenter.default.post(name: NSNotification.Name.init("tick"), object: nil)
    
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }
}

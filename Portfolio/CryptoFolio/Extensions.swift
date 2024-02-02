//
//  Extensions.swift
//  CryptoFolio
//
//  Created by Macbook on 18/12/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import Cocoa
 
extension String {
  var isNumeric: Bool {
    let nums: Set<Character> = [".", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    return nums.isSuperset(of: Set.init(self))
  }
}
enum InterfaceStyle : String {
  case Dark, Light
  
  init() {
    let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
    self = InterfaceStyle(rawValue: type)!
  }
}

extension NSColor {
  static let redy = NSColor.init(red: 15.0/255.0, green: 144.0/255.0, blue: 88.0/255.0, alpha: 1.0)
  static let greeny = NSColor.init(red: 219.0/255.0, green: 68.0/255.0, blue: 55.0/255.0, alpha: 1.0)
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

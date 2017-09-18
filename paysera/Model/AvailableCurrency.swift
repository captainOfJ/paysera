//
//  AvailableCurrency.swift
//  paysera
//
//  Created by CaptainMac on 17/09/2017.
//  Copyright © 2017 Captain. All rights reserved.
//

import RealmSwift
import Foundation

///Realm database object for save availabe currency information.
class AvailableCurrency: Object {
  @objc dynamic var name = ""
  @objc dynamic var amount = 0.00
  
  override static func primaryKey() -> String? {
    return "name"
  }
}

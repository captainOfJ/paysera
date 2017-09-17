//
//  Notifications.swift
//  paysera
//
//  Created by CaptainMac on 17/09/2017.
//  Copyright © 2017 Captain. All rights reserved.
//

import Foundation
import NotificationCenter

class Notifications {
  private let CURRENCY_UPDATED = "currencyWasUpdated"
  
  func addCurrencyUpdatedObserver(conttroller: UIViewController, selector: Selector){
    NotificationCenter.default.addObserver(conttroller, selector: selector, name: NSNotification.Name(rawValue: CURRENCY_UPDATED), object: nil)
  }
  
  func removeCurrencyUpdatedObserverObserver(controller: UIViewController){
    NotificationCenter.default.removeObserver(controller, name: NSNotification.Name(rawValue: CURRENCY_UPDATED), object: nil);
  }
  
  func postCurrencyUpdatedNotification() {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CURRENCY_UPDATED), object: nil)
  }
}


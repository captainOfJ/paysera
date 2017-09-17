//
//  Exchange.swift
//  paysera
//
//  Created by CaptainMac on 16/09/2017.
//  Copyright © 2017 Captain. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import RealmSwift

class Bank {
  public var delegate: BankDelegate?
  
  
  public func exchange(qty: String, from: String, to: String) {
    let quantity = qty.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
    let url = "http://api.evp.lt/currency/commercial/exchange/\(quantity)-\(from)/\(to)/latest"
    
    Alamofire.request(url).responseJSON { response in
      let json = JSON(data: response.data!)
      let amount = json["amount"].stringValue
      let currency = json["currency"].stringValue
      self.delegate?.didCheckExchange(currency: currency, amount: Double(amount)!)
      //print(routes)
    }
  }
  
  public func checkExchangeOpportunityWithCommissions(qty: String, fromCurrency: String, toCurrency: String) throws {
    let quantity = Double(qty.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))!
    if fromCurrency == toCurrency {
      throw ExchangeError.sameCurrency
    }
    let commissions = calculateCommissions(amount: quantity)
    let amount = quantity + commissions
    let realm = try! Realm()
    let available = realm.objects(AvailableCurrency.self).filter("name contains '\(fromCurrency)'").first!
    if available.amount < amount {
      throw ExchangeError.notEnough
    }
  }
  
  public func checkExchangeOpportunity(qty: String, fromCurrency: String, toCurrency: String) throws {
    let quantity = Double(qty.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))!
    if fromCurrency == toCurrency {
      throw ExchangeError.sameCurrency
    }
    let realm = try! Realm()
    let available = realm.objects(AvailableCurrency.self).filter("name contains '\(fromCurrency)'").first!
    if available.amount < quantity {
      throw ExchangeError.notEnough
    }
  }
  
  private func calculateCommissions (amount: Double) -> Double {
    let percentage = 0.007
    let commissions = amount *  percentage
    return commissions
  }
  
  public func makeExchange(qty: String, from: String, to: String) {
    let quantity = Double(qty.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))!
    let url = "http://api.evp.lt/currency/commercial/exchange/\(quantity)-\(from)/\(to)/latest"
    
    Alamofire.request(url).responseJSON { response in
      let json = JSON(data: response.data!)
      let amount = json["amount"].stringValue
      let currency = json["currency"].stringValue
      let decrease = quantity
      self.decreaseCurrencyInDatabase(currency: from, minus: decrease)
      self.increaseCurrencyInDatabase(currency: to, plus: Double(amount)!)
      //update data in database after exchange
      self.delegate?.didMakeExchange(fromCurrency: from, fromAmount: quantity, toCurrency: currency ,toAmount: Double(amount)!)
    }
  }
  
  public func makeExchangeWithCommissions(qty: String, from: String, to: String) {
    let quantity = Double(qty.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil))!
    let url = "http://api.evp.lt/currency/commercial/exchange/\(quantity)-\(from)/\(to)/latest"
    
    Alamofire.request(url).responseJSON { response in
      let json = JSON(data: response.data!)
      let amount = json["amount"].stringValue
      let currency = json["currency"].stringValue
      let commissions = self.calculateCommissions(amount: quantity)
      let decrease = quantity + commissions
      self.decreaseCurrencyInDatabase(currency: from, minus: decrease)
      self.increaseCurrencyInDatabase(currency: to, plus: Double(amount)!)
      //update data in database after exchange
      self.delegate?.didMakeExchangeWithCommissions(commissions: commissions, fromCurrency: from, fromAmount: quantity, toCurrency: currency ,toAmount: Double(amount)!)
    }
  }
  
  private func increaseCurrencyInDatabase(currency: String, plus: Double) {
    let realm = try! Realm()
    let curencyForIncrease = realm.objects(AvailableCurrency.self).filter("name contains '\(currency)'").first!
    try! realm.write {
      curencyForIncrease.amount += plus
    }
  }
  
  private func decreaseCurrencyInDatabase(currency: String, minus: Double) {
    let realm = try! Realm()
    let curencyForIncrease = realm.objects(AvailableCurrency.self).filter("name contains '\(currency)'").first!
    try! realm.write {
      curencyForIncrease.amount -= minus
    }
  }
  
  public enum ExchangeError: Error{
    case sameCurrency
    case notEnough
  }
}

protocol BankDelegate: class {
  func didCheckExchange(currency: String, amount: Double)
  func didMakeExchangeWithCommissions(commissions: Double, fromCurrency: String, fromAmount: Double, toCurrency:String ,toAmount: Double)
  func didMakeExchange(fromCurrency: String, fromAmount: Double, toCurrency:String ,toAmount: Double)
}

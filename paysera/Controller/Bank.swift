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
  
  /// Make currency exchange just for information.
  ///
  /// - Parameters:
  ///   - qty: how much you want exchange
  ///   - from: from what currency
  ///   - to: to what currency
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
  
  /// Check exchange posibility if we calculate and commsions.
  ///
  /// - Parameters:
  ///   - qty: how much exchange
  ///   - fromCurrency: from what currency
  ///   - toCurrency: to what currency
  /// - Throws: why is it inpossible
  public func checkExchangePosibilityWithCommissions(qty: String, fromCurrency: String, toCurrency: String) throws {
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
  
  /// Check exchange posibility without commsions.
  ///
  /// - Parameters:
  ///   - qty: how much exchange
  ///   - fromCurrency: from what currency
  ///   - toCurrency: to what currency
  /// - Throws: why is it inpossible
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
  
  /// Claculate 0.7% exchange commsions.
  ///
  /// - Parameter amount: what amount we exchange
  /// - Returns: commissions amount
  private func calculateCommissions (amount: Double) -> Double {
    let percentage = 0.007
    let commissions = amount *  percentage
    return commissions
  }
  
  /// Make real exchange without commissions, if exchanges succesfull make currency changes in database.
  ///
  /// - Parameters:
  ///   - qty: how much exchange
  ///   - from: from what currency
  ///   - to: to what currency
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
  
  /// Make real exchange with commissions, if exchanges succesfull make currency changes in database.
  ///
  /// - Parameters:
  ///   - qty: how much exchange
  ///   - from: from what currency
  ///   - to: to what currency
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
  
  /// Increase currency in database
  ///
  /// - Parameters:
  ///   - currency: what currency you want increase?
  ///   - plus: how much?
  private func increaseCurrencyInDatabase(currency: String, plus: Double) {
    let realm = try! Realm()
    let curencyForIncrease = realm.objects(AvailableCurrency.self).filter("name contains '\(currency)'").first!
    try! realm.write {
      curencyForIncrease.amount += plus
    }
  }
  
  /// Decrease currency in database
  ///
  /// - Parameters:
  ///   - currency: what currency you want decrease
  ///   - minus: how much ?
  private func decreaseCurrencyInDatabase(currency: String, minus: Double) {
    let realm = try! Realm()
    let curencyForIncrease = realm.objects(AvailableCurrency.self).filter("name contains '\(currency)'").first!
    try! realm.write {
      curencyForIncrease.amount -= minus
    }
  }
  
  /// Currency exhange erros opportunities
  ///
  /// - sameCurrency: exchange with same currency is inposible
  /// - notEnough: not enough currency in database for make exchange.
  public enum ExchangeError: Error{
    case sameCurrency
    case notEnough
  }
}

protocol BankDelegate: class {
  /// Get currency exchange information compleates
  ///
  /// - Parameters:
  ///   - currency: what currency we get
  ///   - amount: how much currency we can get
  func didCheckExchange(currency: String, amount: Double)
  
  
  /// Real exchanges with commissions was completed, and currency data in database is updates.
  ///
  /// - Parameters:
  ///   - commissions: how much commssions payed
  ///   - fromCurrency: from what currency exchange
  ///   - fromAmount: from what amount currency exchange
  ///   - toCurrency: to what currency exhange
  ///   - toAmount: to what amount currency exchange
  func didMakeExchangeWithCommissions(commissions: Double, fromCurrency: String, fromAmount: Double, toCurrency:String ,toAmount: Double)
  
  
  /// Real exchanges with commissions was completed, and currency data in database is updates.
  ///
  /// - Parameters:
  ///   - fromCurrency: from what currency exchange
  ///   - fromAmount: from what amount currency exchange
  ///   - toCurrency: to what currency exhange
  ///   - toAmount: to what amount currency exchange
  func didMakeExchange(fromCurrency: String, fromAmount: Double, toCurrency:String ,toAmount: Double)
}

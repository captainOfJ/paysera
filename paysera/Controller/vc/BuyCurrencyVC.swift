//
//  BuyCurrencyVC.swift
//  paysera
//
//  Created by CaptainMac on 16/09/2017.
//  Copyright © 2017 Captain. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class BuyCurrencyVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
  
  @IBOutlet weak var chooseBuyCurrency: UIPickerView!
  @IBOutlet weak var chooseSettledCurrency: UIPickerView!
  @IBOutlet weak var currencyQty: UITextField!
  @IBOutlet weak var currencyResult: UITextField!
  
  private var tap:UITapGestureRecognizer = UITapGestureRecognizer()
  private let bank = Bank()
  private let infoDialog = InfoDialogVC()
  private let preference = Preferance()
  
  /// get currency exchange information
  ///
  /// - Parameter sender: button
  @IBAction func exchange(_ sender: Any) {
    let qty = currencyQty.text
    if qty!.count > 0 {
      let buyCurrency = SupportedCurrency.currency[chooseBuyCurrency.selectedRow(inComponent: 0)]
      let settledCurrency = SupportedCurrency.currency[chooseSettledCurrency.selectedRow(inComponent: 0)]
      bank.exchange(qty: qty!, from: settledCurrency , to: buyCurrency)
    } else {
      infoDialog.showMe(onViewController: self, message: "Klaida", title: "Prašome įvesti kiekį")
    }
  }
  
  /// approving curency exchange, exchange currency for free if user have that oportunity or with commsions if don't
  ///
  /// - Parameter sender: button
  @IBAction func approved(_ sender: Any) {
    let qty = currencyQty.text
    if qty!.characters.count > 0 {
      let buyCurrency = SupportedCurrency.currency[chooseBuyCurrency.selectedRow(inComponent: 0)]
      let settledCurrency = SupportedCurrency.currency[chooseSettledCurrency.selectedRow(inComponent: 0)]
      do {
        if preference.getLeftFreeTimes() == 0 {
          try bank.checkExchangePosibilityWithCommissions(qty: qty!, fromCurrency: settledCurrency, toCurrency: buyCurrency)
          bank.makeExchangeWithCommissions(qty: qty!, from: settledCurrency, to: buyCurrency)
        } else {
          try bank.checkExchangeOpportunity(qty: qty!, fromCurrency: settledCurrency, toCurrency: buyCurrency)
          bank.makeExchange(qty: qty!, from: settledCurrency, to: buyCurrency)
        }
        
      } catch Bank.ExchangeError.sameCurrency{
        infoDialog.showMe(onViewController: self, message: "Konvertuojamos valiutos negali būti vienodos", title: "KLAIDA")
      } catch Bank.ExchangeError.notEnough {
        infoDialog.showMe(onViewController: self, message: "Jūsų turima \(settledCurrency) suma yra per maza atlikti valiutos konvertacija", title: "KLAIDA")
      } catch {
        
      }
    } else {
      infoDialog.showMe(onViewController: self, message: "Prašome įvesti kiekį", title: "Klaida")
    }
  }
  
  override func viewDidLoad() {
    chooseBuyCurrency.tag = 1
    chooseSettledCurrency.tag = 2
    chooseBuyCurrency.dataSource = self
    chooseBuyCurrency.delegate = self
    chooseSettledCurrency.dataSource = self
    chooseSettledCurrency.delegate = self
    bank.delegate = self
    
    currencyQty.delegate = self
    currencyResult.delegate = self
    currencyResult.isUserInteractionEnabled = false
    
    tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
  }
  
  override func viewDidAppear(_ animated: Bool) {
    chooseBuyCurrency.selectRow(1, inComponent: 0, animated: false)
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    parent!.view.addGestureRecognizer(tap)
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    // set maximum text lenght in textField
    guard let text = textField.text else { return true }
    let newLength = text.characters.count + string.characters.count - range.length
    return newLength <= 10
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView.tag == 1 {
      return SupportedCurrency.currency.count
    } else {
      return SupportedCurrency.currency.count
    }
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    // init how picker view looks.
    let pickerLabel = UILabel()
    pickerLabel.textColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    if pickerView.tag == 1 {
      pickerLabel.text = SupportedCurrency.currency[row]
    } else {
      pickerLabel.text = SupportedCurrency.currency[row]
    }
    pickerLabel.font = UIFont.boldSystemFont(ofSize: 17)// In this use your custom font
    pickerLabel.textAlignment = NSTextAlignment.center
    return pickerLabel
  }
  
  /// for hide keyboard
  @objc func dismissKeyboard() {
    parent!.view.removeGestureRecognizer(tap)
    view.endEditing(true)
  }
}

extension BuyCurrencyVC: BankDelegate {
  
  func didMakeExchange(fromCurrency: String, fromAmount: Double, toCurrency: String, toAmount: Double) {
    infoDialog.showMe(onViewController: self, message: "Jūs konvertavote \(fromAmount) \(fromCurrency) į \(toAmount) \(toCurrency). Komisinis mokestis - 0.00 \(fromCurrency).", title: "KONVERTAVIMAS SEKMINGAS")
    let notifications = Notifications()
    preference.setLeftFreeTimes(times: preference.getLeftFreeTimes() - 1)
    notifications.postCurrencyUpdatedNotification()
  }
  
  func didMakeExchangeWithCommissions(commissions: Double, fromCurrency: String, fromAmount: Double, toCurrency: String, toAmount: Double) {
    let commissionsStr = String(format:"%.2f", commissions)
    infoDialog.showMe(onViewController: self, message: "Jūs konvertavote \(fromAmount) \(fromCurrency) į \(toAmount) \(toCurrency). Komisinis mokestis - \(commissionsStr) \(fromCurrency).", title: "KONVERTAVIMAS SEKMINGAS")
    let notifications = Notifications()
    notifications.postCurrencyUpdatedNotification()
  }
  
  func didCheckExchange(currency: String, amount: Double) {
    print("result after exchange check: \(amount) \(currency)")
    currencyResult.text = "\(amount) \(currency)"
  }
}

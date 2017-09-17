//
//  SellCurrencyVC.swift
//  paysera
//
//  Created by CaptainMac on 16/09/2017.
//  Copyright © 2017 Captain. All rights reserved.
//

import Foundation
import UIKit


class SellCurrencyVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
  
  @IBOutlet weak var chooseSellCurrency: UIPickerView!
  @IBOutlet weak var chooseGetCurrency: UIPickerView!
  @IBOutlet weak var currencyQty: UITextField!
  @IBOutlet weak var currencyResult: UITextField!
  
  private let bank = Bank();
  private let preference = Preferance()
  private var tap:UITapGestureRecognizer = UITapGestureRecognizer()
  private let infoDialog = InfoDialogVC()
  
  @IBAction func exchange(_ sender: Any) {
    let qty = currencyQty.text
    if qty!.characters.count > 0 {
      let sellCurrency = SupportedCurrency.currency[chooseSellCurrency.selectedRow(inComponent: 0)]
      let getCurrency = SupportedCurrency.currency[chooseGetCurrency.selectedRow(inComponent: 0)]
      bank.exchange(qty: qty!, from: sellCurrency , to: getCurrency)
    } else {
      infoDialog.showMe(onViewController: self, message: "Klaida", title: "Prašome įvesti kiekį")
    }
  }
  
  @IBAction func approve(_ sender: Any) {
    let qty = currencyQty.text
    if qty!.characters.count > 0 {
      let sellCurrency = SupportedCurrency.currency[chooseSellCurrency.selectedRow(inComponent: 0)]
      let getCurrency = SupportedCurrency.currency[chooseGetCurrency.selectedRow(inComponent: 0)]
      do {
        if preference.getLeftFreeTimes() == 0 {
          try bank.checkExchangeOpportunityWithCommissions(qty: qty!, fromCurrency: sellCurrency, toCurrency: getCurrency)
          bank.makeExchangeWithCommissions(qty: qty!, from: sellCurrency, to: getCurrency)
        } else {
          try bank.checkExchangeOpportunity(qty: qty!, fromCurrency: sellCurrency, toCurrency: getCurrency)
          bank.makeExchange(qty: qty!, from: sellCurrency, to: getCurrency)
        }
        
      } catch Bank.ExchangeError.sameCurrency{
        infoDialog.showMe(onViewController: self, message: "Konvertuojamos valiutos negali būti vienodos", title: "KLAIDA")
      } catch Bank.ExchangeError.notEnough {
        infoDialog.showMe(onViewController: self, message: "Jūsų turima \(sellCurrency) suma yra per maza atlikti valiutos konvertacija", title: "KLAIDA")
      } catch {
        
      }
    } else {
      infoDialog.showMe(onViewController: self, message: "Prašome įvesti kiekį", title: "Klaida")
    }
  }
  
  override func viewDidLoad() {
    chooseSellCurrency.tag = 1
    chooseGetCurrency.tag = 2
    chooseSellCurrency.dataSource = self
    chooseSellCurrency.delegate = self
    chooseGetCurrency.dataSource = self
    chooseGetCurrency.delegate = self
    bank.delegate = self
    
    currencyQty.delegate = self
    currencyResult.delegate = self
    
    tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
  }
  
  override func viewDidAppear(_ animated: Bool) {
    initView()
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    parent!.view.addGestureRecognizer(tap)
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
  
  private func initView() {
    currencyResult.isUserInteractionEnabled = false
    chooseSellCurrency.selectRow(1, inComponent: 0, animated: false)
  }
  
  @objc func dismissKeyboard() {
    parent!.view.removeGestureRecognizer(tap)
    view.endEditing(true)
  }
}

extension SellCurrencyVC: BankDelegate {
  
  func didMakeExchange(fromCurrency: String, fromAmount: Double, toCurrency: String, toAmount: Double) {
    infoDialog.showMe(onViewController: self, message: "Jūs konvertavote \(fromAmount) \(fromCurrency) į \(toAmount) \(toCurrency). Komisinis mokestis - 0.00 \(fromCurrency).", title: "KONVERTAVIMAS SEKMINGAS")
    let notifications = Notifications()
    preference.setLeftFreeTimes(times: preference.getLeftFreeTimes() - 1)
    notifications.postCurrencyUpdatedNotification()
  }
  
  func didMakeExchangeWithCommissions (commissions: Double, fromCurrency: String, fromAmount: Double, toCurrency: String, toAmount: Double) {
    //print("result after exchange with commissions: \(amount) \(currency)")
    let commissionsStr = String(format:"%.2f", commissions)
    infoDialog.showMe(onViewController: self, message: "Jūs konvertavote \(fromAmount) \(fromCurrency) į \(toAmount) \(toCurrency). Komisinis mokestis - \(commissionsStr) \(fromCurrency).", title: "KONVERTAVIMAS SEKMINGAS")
    let notifications = Notifications()
    notifications.postCurrencyUpdatedNotification()
  }
  
  func didCheckExchange(currency: String, amount: Double) {
    print("result after exchange: \(amount) \(currency)")
    currencyResult.text = "\(amount) \(currency)"
  }
}

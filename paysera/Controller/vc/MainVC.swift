//
//  ViewController.swift
//  paysera
//
//  Created by CaptainMac on 16/09/2017.
//  Copyright © 2017 Captain. All rights reserved.
//

import UIKit
import RealmSwift

class MainVC: UIViewController {
  
  private let exchange = Bank()
  private let preferanceControl = Preferance()
  
  @IBOutlet weak var eurAvailable: UILabel!
  @IBOutlet weak var usdAvailable: UILabel!
  @IBOutlet weak var jpyAvailable: UILabel!
  @IBOutlet weak var buyCurrencyView: UIView!
  @IBOutlet weak var sellCurrencyView: UIView!
  
  @IBAction func buyOrSell(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      buyCurrencyView.isHidden = false
      sellCurrencyView.isHidden = true
      break
    case 1:
      buyCurrencyView.isHidden = true
      sellCurrencyView.isHidden = false
      break
    default:
      break
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    buyCurrencyView.isHidden = false
    sellCurrencyView.isHidden = true
    let notifications = Notifications()
    notifications.addCurrencyUpdatedObserver(conttroller: self, selector: #selector(showData))
    
    //check or this is first app launch
    let isLaunched = preferanceControl.getOrAppLaunchedBefore();
    if !isLaunched {
      initFirstLaunch()
    }
    showData();
  }
  
  /// init application data in first launched, add currency values to database and set
  /// free exchanges posibilitys times and save to UsersDefaults.
  private func initFirstLaunch() {
    preferanceControl.setAppLaunched()
    preferanceControl.setLeftFreeTimes(times: 5)
    
    let eurCurrency = AvailableCurrency()
    eurCurrency.name = SupportedCurrency.EUR
    eurCurrency.amount = 1000.00
    let usdCurrency = AvailableCurrency()
    usdCurrency.name = SupportedCurrency.USD
    usdCurrency.amount = 0.00
    let jpyCurrency = AvailableCurrency()
    jpyCurrency.name = SupportedCurrency.JPY
    jpyCurrency.amount = 0.00
    
    let realm = try! Realm()
    try! realm.write {
      realm.add(eurCurrency)
      realm.add(usdCurrency)
      realm.add(jpyCurrency)
    }
  }
  
  /// Show currency data from database.
  @objc private func showData() {
    let realm = try! Realm()
    let availableEur = realm.objects(AvailableCurrency.self).filter("name contains '\(SupportedCurrency.EUR)'").first
    let availableUsd = realm.objects(AvailableCurrency.self).filter("name contains '\(SupportedCurrency.USD)'").first
    let availableJpy = realm.objects(AvailableCurrency.self).filter("name contains '\(SupportedCurrency.JPY)'").first
    let eur = availableEur!.amount
    let usd = availableUsd!.amount
    let jpy = availableJpy!.amount
    
    eurAvailable.text = String(format:"%.2f", eur)
    usdAvailable.text = String(format:"%.2f", usd)
    jpyAvailable.text = String(format:"%.2f", jpy)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}


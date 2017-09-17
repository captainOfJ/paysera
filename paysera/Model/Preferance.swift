//
//  PreferanceControl.swift
//  paysera
//
//  Created by CaptainMac on 17/09/2017.
//  Copyright © 2017 Captain. All rights reserved.
//

import Foundation
class Preferance {
  private let FREE_TIME = "FreeTime"
  private let LAUNCHED_BEFORE = "launchedBefore"
  
  /// Save data how mutch time, user can make free exchange.
  ///
  /// - Parameter times: how many left
  func setLeftFreeTimes(times: Int) {
    let preferences = UserDefaults.standard
    preferences.set(times, forKey: FREE_TIME)
    preferences.synchronize()
  }
  
  /// Get data how mutch time, user can make free exchange.
  ///
  /// - Returns: how many left
  func getLeftFreeTimes() -> Int {
    let preferences = UserDefaults.standard
    let times = preferences.integer(forKey: FREE_TIME)
    return times
  }
  
  /// Set status, applicaton been launched.
  func setAppLaunched() {
    let preferences = UserDefaults.standard
    preferences.set(true, forKey: LAUNCHED_BEFORE)
    preferences.synchronize()
  }
  
  /// Get status, or application be launched before
  ///
  /// - Returns: launched status
  func getOrAppLaunchedBefore() -> Bool {
    let preferences = UserDefaults.standard
    let isLaunchedBefore = preferences.bool(forKey: LAUNCHED_BEFORE)
    return isLaunchedBefore
  }
  
}

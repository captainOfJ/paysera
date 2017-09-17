//
//  TextFieldStyle.swift
//  paysera
//
//  Created by CaptainMac on 17/09/2017.
//  Copyright © 2017 Captain. All rights reserved.
//

import Foundation
import UIKit

class TextFieldStyle: UITextField {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.borderStyle = .none
    self.layer.backgroundColor = UIColor(red: 80.0/255.0, green: 145.0/255.0, blue: 255.0/255.0, alpha: 1.00).cgColor
    
    self.layer.masksToBounds = false
    self.layer.shadowColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
    self.layer.shadowOffset = CGSize(width: 0.0, height: 1.2)
    self.layer.shadowOpacity = 1.0
    self.layer.shadowRadius = 0.0
    
    self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor:  UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.00)])
    
  }
  
}

//
//  RoundButton.swift
//  paysera
//
//  Created by CaptainMac on 16/09/2017.
//  Copyright © 2017 Captain. All rights reserved.
//

import Foundation
import UIKit

//@IBDesignable
class RoundButton: UIButton {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    layer.shadowOpacity = 0.8
    layer.shadowRadius = 5.0
    layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    imageView?.contentMode = .scaleAspectFit
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    layer.cornerRadius = self.bounds.size.width * 0.5
  }
  
}

//
//  InfoDialogVC.swift
//  paysera
//
//  Created by CaptainMac on 17/09/2017.
//  Copyright © 2017 Captain. All rights reserved.
//

import Foundation
import UIKit

/// Dialog viewController to show information for user.
class InfoDialogVC: UIViewController {
  
  var dialogMessage: String!
  var dialogTitle: String!
  
  @IBOutlet weak var dialogView: UIView!
  @IBOutlet weak var messageLA: UILabel!
  @IBOutlet weak var titleLA: UILabel!
  
  @IBAction func ok(_ sender: Any) {
    removeAnimate()
  }
  
  override func viewDidLoad() {
    dialogView.layer.cornerRadius = 10
    dialogView.layer.borderWidth = 2
    dialogView.layer.borderColor = UIColor.white.cgColor
    view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    
    messageLA.text = dialogMessage // what message need to show
    titleLA.text = dialogTitle // what title need to show
  }
  
  override func viewDidAppear(_ animated: Bool) {
    showAnimate()
  }
  
  /// function for show information dialog view
  ///
  /// - Parameters:
  ///   - onViewController: on what view controller need to show this view
  ///   - message: message in dialog
  ///   - title: dialog title text
  public func showMe(onViewController: UIViewController, message: String, title: String){
    let dialog = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "infoDialogVC") as! InfoDialogVC
    dialog.dialogMessage = message
    dialog.dialogTitle = title
    dialog.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    onViewController.present(dialog, animated: false, completion: nil)
  }
  
  /// animate for dialog present
  private func showAnimate() {
    self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
    self.view.alpha = 0.0;
    UIView.animate(withDuration: 0.25, animations: {
      self.view.alpha = 1.0
      self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    });
  }
  
  /// animate for dialog remove
  private func removeAnimate() {
    UIView.animate(withDuration: 0.25, animations: {
      self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
      self.view.alpha = 0.0;
    }, completion:{(finished : Bool)  in
      if (finished) {
        self.dismiss(animated: false, completion: nil)
      }
    });
  }
  
}

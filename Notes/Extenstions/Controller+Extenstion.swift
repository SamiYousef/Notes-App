//
//  Controller+Extenstion.swift
//  Notes
//
//  Created by Sami Youssef on 9/15/18.
//  Copyright © 2018 Sami Youssef. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

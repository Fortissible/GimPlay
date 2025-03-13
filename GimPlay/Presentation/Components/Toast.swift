//
//  Toast.swift
//  GimPlay
//
//  Created by Wildan on 14/03/25.
//

import Foundation
import UIKit

extension UIView {
    func showToast(message: String, duration: Double = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: self.frame.size.width / 2 - 150,
                                               y: self.frame.size.height - 200,
                                               width: 300,
                                               height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.addSubview(toastLabel)
 
        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

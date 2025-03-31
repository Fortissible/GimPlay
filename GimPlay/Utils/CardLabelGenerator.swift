//
//  CardLabelGenerator.swift
//  GimPlay
//
//  Created by Wildan on 09/03/25.
//

import Foundation
import UIKit

func cardLabelGenerator(_ content: String) -> UILabel {
    let label = UILabel()

    label.text = content
    label.textAlignment = .center
    label.backgroundColor = .systemBlue
    label.textColor = .white
    label.layer.cornerRadius = 10
    label.layer.masksToBounds = true
    label.widthAnchor.constraint(equalToConstant: 80).isActive = true
    label.heightAnchor.constraint(equalToConstant: 80).isActive = true

    return label
}

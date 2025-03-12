//
//  GameCardViewCell.swift
//  GimPlay
//
//  Created by Wildan on 07/03/25.
//

import UIKit

class GameCardViewCell: UITableViewCell {

    @IBOutlet weak var gameImageLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gameRatingView: UILabel!
    @IBOutlet weak var gameReleasedView: UILabel!
    @IBOutlet weak var gameGenresView: UILabel!
    @IBOutlet weak var gameTitleView: UILabel!
    @IBOutlet weak var gameImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

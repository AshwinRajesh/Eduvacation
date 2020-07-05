//
//  TripTableViewCell.swift
//  Eduvacation
//
//  Created by Ashwin Rajesh on 7/3/20.
//  Copyright © 2020 AshwinR. All rights reserved.
//

import UIKit

class TripTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var graphic: UILabel!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var name: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

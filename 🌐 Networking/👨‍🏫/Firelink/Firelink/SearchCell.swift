//
//  SearchCell.swift
//  Firelink
//
//  Created by jimlai on 2018/9/3.
//  Copyright © 2018年 jimlai. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet var repo: UILabel!
    @IBOutlet var url: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

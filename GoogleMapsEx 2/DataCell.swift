//
//  DataCell.swift
//  GoogleMapsEx
//
//  Created by M Shankar on 30/03/21.
//

import UIKit

class DataCell: UITableViewCell {

    @IBOutlet weak var Cview: UIView!
    @IBOutlet weak var detailsText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

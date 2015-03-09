//
//  HistoryTableViewCell.swift
//  Near
//
//  Created by Petteri Noponen on 9.3.2015.
//  Copyright (c) 2015 aalto. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    var place: Place? {
        didSet {
            updateUI()
        }
    }

    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeDescription: UILabel!

    func updateUI() {
        placeName?.text = nil
        placeDescription?.text = nil

        if let place = self.place {
            placeName?.text = place.name
            placeDescription?.text = place.description
        }
    }

    func tweakSizeAccordingToTable(tableView: UITableView) {
        let labelWidth = CGRectGetWidth(tableView.frame) - CGFloat(2*ViewConstants.verticalMarginWidth)

        placeName?.preferredMaxLayoutWidth = labelWidth
        placeDescription?.preferredMaxLayoutWidth = labelWidth
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

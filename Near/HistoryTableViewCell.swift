//
//  HistoryTableViewCell.swift
//  Near
//
//  Created by Petteri Noponen on 9.3.2015.
//  Copyright (c) 2015 aalto. All rights reserved.
//

import UIKit

class HistoryTableViewCell: MGSwipeTableCell {

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

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        let marginleft = 30
        let detailContainer =  UIView(frame: CGRect(x: marginleft, y: 25, width: 0, height: 0))
        detailContainer.backgroundColor = UIColor.brownColor()
        let fontName = "Roboto-Regular"
        let cityFont = UIFont(name: fontName, size: 11)

        let cityLabel = UILabel(frame: CGRect(x: 0, y:0, width:0, height: 0))
        cityLabel.font = cityFont
        cityLabel.alpha = 0.6

        let lastVisitLabel = UILabel(frame: CGRect(x: 0, y: 15, width:0, height:0))
        lastVisitLabel.font = UIFont(name: fontName, size: 9)
        lastVisitLabel.alpha = 0.5

        if let place = self.place {
            placeName?.text = place.name
            placeDescription?.text = place.descriptionText
            cityLabel.text = place.city
            lastVisitLabel.text = formatLastVisitTime(place.lastVisit)
            setAlphaBasedOnLastVisit(place)
        }

        cityLabel.sizeToFit()
        lastVisitLabel.sizeToFit()

        detailContainer.addSubview(cityLabel)
        detailContainer.addSubview(lastVisitLabel)

        var adjustedFrame = view.frame
        adjustedFrame.size.width = CGFloat(marginleft) + max(cityLabel.frame.width, lastVisitLabel.frame.width)
        view.frame = adjustedFrame
        view.addSubview(detailContainer)

        self.rightSwipeSettings.transition = MGSwipeTransition.TransitionBorder
        self.leftButtons = [view]

    }

    func formatLastVisitTime(date: NSDate) -> String {
        let seconds = Int(NSDate().timeIntervalSinceDate(date))
        let secondsInMinute = 60
        let secondsInHour = 60 * secondsInMinute
        let secondsInDay = 24 * secondsInHour
        let secondsInMonth = 30 * secondsInDay
        let secondsInYear = 365 * secondsInDay
        let secondsInWeek = 7 * secondsInDay

        if(seconds > secondsInYear) {
            return "\(Int(seconds / secondsInYear)) y ago"
        }
        else if(seconds > secondsInMonth) {
            return "\(Int(seconds / secondsInMonth)) m ago"
        }
        else if(seconds > secondsInWeek) {
            return "\(Int(seconds / secondsInWeek)) w ago"
        }
        else if(seconds > secondsInDay) {
            return "\(Int(seconds / secondsInDay)) d ago"
        }
        else if(seconds > secondsInHour) {
            return "\(Int(seconds / secondsInHour)) h ago"
        }
        else {
            return "\(Int(seconds / secondsInMinute)) min ago"
        }
    }

    func setAlphaBasedOnLastVisit(place : Place) {
        let oneDayInSeconds = 60 * 60 * 24
        let tooOldVisitTime = oneDayInSeconds
        let visitAge = Int(NSDate().timeIntervalSinceDate(place.lastVisit));
        contentView.alpha = visitAge > tooOldVisitTime ? 0.5 : 1
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

//
//  DateCollectionCell.swift
//  DateWheelPicker
//
//  Created by Trần Mạnh Quý on 9/16/20.
//  Copyright © 2020 Trần Mạnh Quý. All rights reserved.
//

import UIKit

class DateCollectionCell: UICollectionViewCell, DateItemInterface {

    @IBOutlet weak var labelMonth: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelWeekDay: UILabel!
    @IBOutlet weak var indicator: UIView!
    
    var index = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.isCenter(false)
    }
    
    func isCenter(_ center: Bool = true) {
        labelMonth.textColor = center ? UIColor.black : UIColor.lightGray
        labelDate.textColor = center ? UIColor.black : UIColor.lightGray
        labelWeekDay.textColor = center ? UIColor.black : UIColor.lightGray
        indicator.isHidden = !center
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.isCenter(false)
    }
}

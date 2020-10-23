//
//  ViewController.swift
//  HorizontalDatePicker
//
//  Created by Trần Mạnh Quý on 10/23/20.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale.current
        return formatter
    }()

    @IBOutlet weak var dateSlider: DateWheelPicker!
    @IBOutlet weak var labelSelectedDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelSelectedDate.text = dateFormatter.string(from: dateSlider.getCurrentDate())
        dateSlider.onSelectedDate { [weak self] (date) in
            print(date.description)
            self?.labelSelectedDate.text = self?.dateFormatter.string(from: date)
        }
    }
}


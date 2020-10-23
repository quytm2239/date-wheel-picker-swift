//
//  Extension.swift
//  DateWheelPicker
//
//  Created by Trần Mạnh Quý on 9/16/20.
//  Copyright © 2020 Trần Mạnh Quý. All rights reserved.
//

import UIKit

extension NSObject {
    static var typeName: String {
        return String(describing: self)
    }
    var objectName: String {
        return String(describing: type(of: self))
    }
}

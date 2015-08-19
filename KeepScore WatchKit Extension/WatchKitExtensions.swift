//
//  WatchKitExtensions.swift
//  KeepScore
//
//  Created by Jeff Kempista on 8/18/15.
//  Copyright © 2015 Jeff Kempista. All rights reserved.
//

import WatchKit
import Foundation

extension WKPickerItem {
    convenience init(title: String) {
        self.init()
        self.title = title
    }
}

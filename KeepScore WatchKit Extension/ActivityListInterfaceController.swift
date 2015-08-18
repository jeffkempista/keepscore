//
//  ActivityListInterfaceController.swift
//  KeepScore
//
//  Created by Jeff Kempista on 8/17/15.
//  Copyright © 2015 Jeff Kempista. All rights reserved.
//

import HealthKit
import WatchKit
import Foundation

class ActivityListInterfaceController: WKInterfaceController {
    
    let supportedActivities: [HKWorkoutActivityType] = [.Baseball, .Basketball, .Hockey, .Soccer, .TableTennis, .Volleyball]
    
    @IBOutlet var activityTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        loadSupportedActivities()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    private func loadSupportedActivities() {
        activityTable.setNumberOfRows(supportedActivities.count, withRowType: "ActivityTableRowController")
        
        for (index, activityType) in supportedActivities.enumerate() {
            let row = activityTable.rowControllerAtIndex(index) as! ActivityTableRowController
            row.titleLabel.setText(activityType.getTitle())
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        
        let selectedActitity = supportedActivities[rowIndex]
        
        return WorkoutSessionContext(activityType: selectedActitity)
    }
    
}

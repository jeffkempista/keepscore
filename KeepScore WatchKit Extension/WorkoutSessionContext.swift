//
//  WorkoutSessionContext.swift
//  KeepScore
//
//  Created by Jeff Kempista on 8/17/15.
//  Copyright © 2015 Jeff Kempista. All rights reserved.
//

import HealthKit
import Foundation

class WorkoutSessionContext {
    
    let activityType: HKWorkoutActivityType
    var homeTeam: String?
    var awayTeam: String?
    
    init(activityType: HKWorkoutActivityType) {
        self.activityType = activityType
    }
    
}

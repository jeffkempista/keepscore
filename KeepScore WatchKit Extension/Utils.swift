//
//  Utils.swift
//  KeepScore
//
//  Created by Jeff Kempista on 8/17/15.
//  Copyright © 2015 Jeff Kempista. All rights reserved.
//

import HealthKit

extension HKWorkoutActivityType {
    
    func getTitle() -> String {
        switch (self) {
        case .Baseball:
            return "Baseball"
        case .Basketball:
            return "Basketball"
        case .Hockey:
            return "Hockey"
        case .Soccer:
            return "Soccer"
        case .TableTennis:
            return "Table Tennis"
        case .Volleyball:
            return "Volleyball"
        default:
            return "Other"
        }
    }
    
}

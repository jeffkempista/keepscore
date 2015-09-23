import HealthKit
import Foundation

extension HKQuantity {
    
    func addQuantitiesFromSamples(samples: [HKQuantitySample], unit: HKUnit) -> HKQuantity {
        
        var total = 0.0
        for (_, sample) in samples.enumerate() {
            total += sample.quantity.doubleValueForUnit(unit)
        }
        return HKQuantity(unit: unit, doubleValue: total)
    }
    
}

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

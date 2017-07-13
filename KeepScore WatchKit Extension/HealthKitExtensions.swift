import HealthKit
import Foundation

extension HKQuantity {
    
    func addQuantitiesFromSamples(_ samples: [HKQuantitySample], unit: HKUnit) -> HKQuantity {
        
        var total = 0.0
        for (_, sample) in samples.enumerated() {
            total += sample.quantity.doubleValue(for: unit)
        }
        return HKQuantity(unit: unit, doubleValue: total)
    }
    
}

extension HKWorkoutActivityType {
    
    func getTitle() -> String {
        switch (self) {
        case .baseball:
            return "Baseball"
        case .basketball:
            return "Basketball"
        case .hockey:
            return "Hockey"
        case .soccer:
            return "Soccer"
        case .tableTennis:
            return "Table Tennis"
        case .volleyball:
            return "Volleyball"
        default:
            return "Other"
        }
    }
    
}

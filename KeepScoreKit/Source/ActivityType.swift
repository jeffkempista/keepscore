import Foundation
import HealthKit

public enum ActivityType : String {
 
    case Baseball
    case Basketball
    case Hockey
    case Soccer
    case TableTennis
    case Volleyball
    case Other
    
    public func getTitle() -> String {
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
    
    public func getWorkoutActivityType() -> HKWorkoutActivityType {
        switch (self) {
        case .Baseball:
            return .baseball
        case .Basketball:
            return .basketball
        case .Hockey:
            return .hockey
        case .Soccer:
            return .soccer
        case .TableTennis:
            return .tableTennis
        case .Volleyball:
            return .volleyball
        default:
            return .other
        }
    }
    
}

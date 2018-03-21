import Foundation.NSDate

@objc public class Passenger : NSObject {
    public private(set) var name: String
    private(set) var startWaiting = Date()
    private(set) var startRiding: Date?
    private(set) var arrived: Date?
    
    public var timeSpentRiding: TimeInterval? {
        guard startRiding != nil else {
            return 0
        }
        guard arrived != nil else {
            return nil
        }
        
        return arrived!.timeIntervalSince(startRiding!)
    }
    
    public var timeSpentWaiting: TimeInterval {
        if let arrived = self.arrived {
            return arrived.timeIntervalSince(startWaiting)
        }
        return Date().timeIntervalSince(startWaiting)
    }
    
    public init(name: String? = nil) {
        if let name = name {
            self.name = name
        } else {
            let sy = ["ba", "to", "so", "ri", "ta", "ma", "ne"]
            let nb = [3, 4, 5, 6][Int(arc4random_uniform(4))]
            
            var name = ""
            for _ in 0..<nb {
                name += sy[Int(arc4random_uniform(UInt32(sy.count)))]
            }
            
            self.name = name
        }
    }
}

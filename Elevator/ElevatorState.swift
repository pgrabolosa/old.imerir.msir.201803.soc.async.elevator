import Foundation

@objc public enum ElevatorState : Int, CustomDebugStringConvertible {
    case idle
    case opened
    case movingDown
    case movingUp
    case opening
    case closing
    
    public var debugDescription: String {
        switch self {
        case .idle:       return "@rest, doors closed"
        case .opened:     return "@rest, doors opened"
        case .movingDown: return "moving down"
        case .movingUp:   return "moving up"
        case .opening:    return "@rest, doors opening"
        case .closing:    return "@rest, doors closing"
        }
    }
}

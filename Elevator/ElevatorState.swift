import Foundation

@objc public enum ElevatorState : Int {
    case idle
    case opened
    case movingDown
    case movingUp
    case opening
    case closing
}

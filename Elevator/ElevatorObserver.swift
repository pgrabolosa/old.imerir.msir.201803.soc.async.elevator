public protocol ElevatorObserver {
    func elevator(_ elevator: Elevator, willChangeFloorFrom from: Int, to: Int)
    func elevator(_ elevator: Elevator, didChangeFloorFrom from: Int, to: Int)
    
    func elevator(_ elevator: Elevator, willChangeLoadFrom from: Int, to: Int)
    func elevator(_ elevator: Elevator, didChangeLoadFrom from: Int, to: Int)
    
    func elevator(_ elevator: Elevator, willChangeStateFrom from: ElevatorState, to: ElevatorState)
    func elevator(_ elevator: Elevator, didChangeStateFrom from: ElevatorState, to: ElevatorState)
}

// make implementation optional
extension ElevatorObserver {
    public func elevator(_ elevator: Elevator, willChangeFloorFrom from: Int, to: Int) {}
    public func elevator(_ elevator: Elevator, didChangeFloorFrom from: Int, to: Int) {}
    public func elevator(_ elevator: Elevator, willChangeStateFrom from: ElevatorState, to: ElevatorState) {}
    public func elevator(_ elevator: Elevator, didChangeStateFrom from: ElevatorState, to: ElevatorState) {}
    public func elevator(_ elevator: Elevator, willChangeLoadFrom from: Int, to: Int) {}
    public func elevator(_ elevator: Elevator, didChangeLoadFrom from: Int, to: Int) {}
}

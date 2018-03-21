public protocol ElevatorObserver {
    func elevator(_ elevator: Elevator, willChangeFloorFrom from: Int, to: Int)
    func elevator(_ elevator: Elevator, didChangeFloorFrom from: Int, to: Int)
    
    func elevator(_ elevator: Elevator, willChangeLoadFrom from: Int, to: Int)
    func elevator(_ elevator: Elevator, didChangeLoadFrom from: Int, to: Int)

    func elevatorWillCloseDoor(_ elevator: Elevator)
    func elevatorDidCloseDoor(_ elevator: Elevator)
    
    func elevatorWillOpenDoor(_ elevator: Elevator)
    func elevatorDidOpenDoor(_ elevator: Elevator)
}

// make implementation optional
extension ElevatorObserver {
    public func elevator(_ elevator: Elevator, willChangeFloorFrom from: Int, to: Int) {}
    public func elevator(_ elevator: Elevator, didChangeFloorFrom from: Int, to: Int) {}
    public func elevator(_ elevator: Elevator, willChangeLoadFrom from: Int, to: Int) {}
    public func elevator(_ elevator: Elevator, didChangeLoadFrom from: Int, to: Int) {}
    public func elevatorWillCloseDoor(_ elevator: Elevator) {}
    public func elevatorDidCloseDoor(_ elevator: Elevator) {}
    public func elevatorWillOpenDoor(_ elevator: Elevator) {}
    public func elevatorDidOpenDoor(_ elevator: Elevator) {}

}

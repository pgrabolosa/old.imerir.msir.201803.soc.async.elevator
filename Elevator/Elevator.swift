import Foundation.NSOperation

@objcMembers
public class Elevator : NSObject {
    public var observer: ElevatorObserver?
    
    public private(set) var durations = ElevatorDurations()
    
    /// A synchronizing queue to make this object operations thread-safe.
    private let lock = DispatchQueue(label: "elevator.lock")
    
    public private(set) var floorBounds = (lower: 0, upper: 5)
    public private(set) var currentFloor: Int
    public private(set) var load = 0
    public private(set) var state = ElevatorState.idle
    public private(set) var maximumLoad = 8
    
    /// This cue holds operations being executed by the elevator. Whenever the queue ends up being empty, the state should be idle.
    private let q = OperationQueue()
    
    public override init() {
        currentFloor = floorBounds.lower
        q.maxConcurrentOperationCount = 1
    }
    
    public func waitForIdle() {
        q.waitUntilAllOperationsAreFinished()
        assert(state == .idle)
    }
    
    public func openDoors() throws {
        try operate(transient: .opening, final: .opened) {
            self.observer?.elevatorWillOpenDoor(self)
            Thread.sleep(forTimeInterval: self.durations.opening)
            return { self.observer?.elevatorDidOpenDoor(self) }
        }
    }
    
    public func closeDoors() throws {
        try operate(required: .opened, transient: .closing, final: .idle) {
            self.observer?.elevatorWillCloseDoor(self)
            Thread.sleep(forTimeInterval: self.durations.closing)
            return { self.observer?.elevatorDidCloseDoor(self) }
        }
    }
    
    public func move(_ direction: Direction) throws {
        let state: ElevatorState = direction == .up ? .movingUp : .movingDown
        
        try operate(transient: state) {
            let origin = self.currentFloor
            let destination = self.currentFloor + direction.rawValue
            
            guard self.floorBounds.lower <= destination && destination <= self.floorBounds.upper else {
                throw ElevatorError.unreachableDestination
            }
            
            self.willChangeValue(for: \.currentFloor)
            self.observer?.elevator(self, willChangeFloorFrom: origin, to: destination)
            
            let sleepDuration = destination > self.currentFloor ?
                self.durations.movingUp :
                self.durations.movingDown
            Thread.sleep(forTimeInterval: sleepDuration)
            
            self.currentFloor = destination
            
            return {
                self.observer?.elevator(self, didChangeFloorFrom: origin, to: destination)
                self.didChangeValue(for: \.currentFloor)
            }
        }
    }
    
    public func loadPassengers(_ count: Int) throws {
        try operate(required: .opened, transient: .opened, final: .opened) {
            for _ in 0..<count {
                let oldValue = self.load
                let newValue = oldValue + 1
                
                self.willChangeValue(for: \.load)
                self.observer?.elevator(self, willChangeLoadFrom: oldValue, to: newValue)
                
                Thread.sleep(forTimeInterval: self.durations.loading)
                if self.load + 1 > self.maximumLoad {
                    throw ElevatorError.reachedMaxLoad
                }
                self.load += 1
                
                self.observer?.elevator(self, didChangeLoadFrom: oldValue, to: newValue)
                self.didChangeValue(for: \.load)
                
            }
            return nil
        }
    }
    
    public func unloadPassengers(_ count: Int) throws {
        try operate(required: .opened, transient: .opened, final: .opened) {
            for _ in 0..<count {
                if self.load - 1 >= 0 {
                    let oldValue = self.load
                    let newValue = oldValue + 1
                    
                    self.willChangeValue(for: \.load)
                    self.observer?.elevator(self, willChangeLoadFrom: oldValue, to: newValue)

                    Thread.sleep(forTimeInterval: self.durations.unloading)
                    self.load -= 1
                    
                    self.observer?.elevator(self, didChangeLoadFrom: oldValue, to: newValue)
                    self.didChangeValue(for: \.load)
                }
            }
            return nil
        }
    }
    
    private func operate(required: ElevatorState = .idle, transient: ElevatorState, final: ElevatorState = .idle, _ action: @escaping () throws -> (() -> Void)?) throws {
        try lock.sync {
            guard required == self.state else {
                throw ElevatorError.cannotOperateUnderCurrentState
            }
            
            self.willChangeValue(for: \Elevator.state)
            self.state = transient
            self.didChangeValue(for: \Elevator.state)
            
            q.addOperation {
                let completion = try! action()
                
                self.willChangeValue(for: \Elevator.state)
                self.state = final
                self.didChangeValue(for: \Elevator.state)
                
                completion?()
            }
        }
    }
}

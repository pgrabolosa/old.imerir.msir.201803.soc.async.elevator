import Foundation.NSOperation

@objcMembers
public class Elevator : NSObject {
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
    }
    
    public func openDoors() throws {
        try operate(finalState: .opened) {
            self.willChangeValue(for: \.state)
            
            self.state = .opening
            Thread.sleep(forTimeInterval: self.durations.opening)
            
            self.didChangeValue(for: \.state)
        }
    }
    
    public func closeDoors() throws {
        try operate(validInitialState: .opened, finalState: .idle) {
            self.willChangeValue(for: \.state)
            
            self.state = .closing
            Thread.sleep(forTimeInterval: self.durations.closing)
            
            self.didChangeValue(for: \.state)
        }
    }
    
    public func move(_ direction: Direction) throws {
        try operate {
            let destination = self.currentFloor + direction.rawValue
            
            guard self.floorBounds.lower <= destination && destination <= self.floorBounds.upper else {
                throw ElevatorError.unreachableDestination
            }
            
            self.willChangeValue(for: \.currentFloor)
            self.willChangeValue(for: \.state)
            
            if destination > self.currentFloor {
                self.state = .movingUp
                Thread.sleep(forTimeInterval: self.durations.movingUp)
            } else {
                self.state = .movingDown
                Thread.sleep(forTimeInterval: self.durations.movingDown)
            }
            self.currentFloor = destination
            
            self.didChangeValue(for: \.state)
            self.didChangeValue(for: \.currentFloor)
        }
    }
    
    public func loadPassengers(_ count: Int) throws {
        try operate(validInitialState: .opened, finalState: .opened) {
            for _ in 0..<count {
                self.willChangeValue(for: \.load)
                
                Thread.sleep(forTimeInterval: self.durations.loading)
                if self.load + 1 > self.maximumLoad {
                    throw ElevatorError.reachedMaxLoad
                }
                self.load += 1
                self.didChangeValue(for: \.load)
            }
        }
    }
    
    public func unloadPassengers(_ count: Int) throws {
        try operate(validInitialState: .opened, finalState: .opened) {
            for _ in 0..<count {
                if self.load - 1 >= 0 {
                    self.willChangeValue(for: \.load)
                    
                    Thread.sleep(forTimeInterval: self.durations.unloading)
                    self.load -= 1
                    
                    self.didChangeValue(for: \.load)
                }
            }
        }
    }
    
    private func operate(validInitialState: ElevatorState = .idle, finalState: ElevatorState = .idle, _ action: @escaping () throws -> Void) throws {
        try lock.sync {
            guard validInitialState == self.state else {
                throw ElevatorError.cannotOperateUnderCurrentState
            }
            
            q.addOperation {
                try! action()
                self.state = finalState
            }
        }
    }
}

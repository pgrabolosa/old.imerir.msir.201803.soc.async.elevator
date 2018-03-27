import UIKit

public class ElevatorView : UIView {
    
    public private(set) var elevator: Elevator
    
    public var numberOfFloors: Int {
        return elevator.floorBounds.upper - elevator.floorBounds.lower
    }
    
    private var elevatorLayer = CALayer()
    private var doorLayer = CALayer()
    
    private var floors: [CALayer] = []
    private var passengers: [CALayer] = []
    
    private var onLoadToken: NSKeyValueObservation?
    private var onStateToken: NSKeyValueObservation?
    private var onFloorToken: NSKeyValueObservation?
    
    public init(_ elevator: Elevator) {
        self.elevator = elevator
        super.init(frame: CGRect())
        
        self.createFloors()
        self.elevatorLayer.backgroundColor = UIColor.darkGray.cgColor
        self.doorLayer.backgroundColor = UIColor.cyan.cgColor
        self.elevatorLayer.addSublayer(self.doorLayer)
        self.layer.addSublayer(elevatorLayer)
        
        onLoadToken = self.elevator.observe(\.load, options: [.old, .new]) { (elevator, _) in
            if self.passengers.count > elevator.load {
                self.removePassenger()
            } else if self.passengers.count < elevator.load {
                self.addPassenger()
            }
        }
        
        onFloorToken = self.elevator.observe(\.currentFloor, options: [.old, .new]) { (_, _) in
            self.moveToCurrentFloor()
        }
        
        onStateToken = self.elevator.observe(\.state, options: [.old, .new]) { (elevator, change) in
            if elevator.state == .opening {
                self.openingDoors()
            } else if elevator.state == .closing {
                self.closingDoors()
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removePassenger() {
        animate {
            self.passengers.removeLast().removeFromSuperlayer()
        }
    }
    
    func addPassenger() {
        animate {
            let newPassenger = CALayer()
            newPassenger.frame = CGRect(origin: CGPoint(x: CGFloat(5 + ((25+5) * self.passengers.count)) , y: (self.elevatorLayer.bounds.height - 25)/2), size: CGSize(width: 25, height: 25))
            newPassenger.backgroundColor = UIColor.black.cgColor
            self.passengers.append(newPassenger)
            self.elevatorLayer.addSublayer(newPassenger)
        }
    }
    
    func closingDoors() {
        animate {
            self.doorLayer.bounds.size.width = 0
        }
    }
    
    func openingDoors() {
        animate {
            self.doorLayer.frame = self.elevatorLayer.bounds
        }
    }
    
    let animationQueue:OperationQueue = {
        let oq = OperationQueue()
        oq.maxConcurrentOperationCount = 1
        return oq
    }()
    
    private func animate(_ animation: @escaping ()->Void) {
        animationQueue.addOperation {
            //self.animationQueue.waitUntilAllOperationsAreFinished()
            let semaphore = DispatchSemaphore(value: 0)
            DispatchQueue.main.sync {
                CATransaction.begin()
                CATransaction.setAnimationDuration(2)
                CATransaction.setCompletionBlock {
                    semaphore.signal()
                }
                
                animation()
                
                CATransaction.commit()
            }
            semaphore.wait()
        }
    }
    
    func moveToCurrentFloor() {
        DispatchQueue.main.async {
            let newLevel = self.elevator.currentFloor
            if 0 <= newLevel && newLevel < self.floors.count {
                self.animate {
                    self.elevatorLayer.frame = self.floors[newLevel].frame
                }
                
                CATransaction.commit()
            }
        }
    }
    
    private func createFloors() {
        for level in 0..<numberOfFloors {
            let floorLayer = CALayer()
            
            floorLayer.frame = floorFrame(at: level)
            floorLayer.borderWidth = 1
            floorLayer.borderColor = UIColor.white.cgColor
            floorLayer.backgroundColor = UIColor.gray.cgColor
            
            floors.append(floorLayer)
            self.layer.addSublayer(floorLayer)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.elevatorLayer.frame = floorFrame(at: elevator.currentFloor)
        self.doorLayer.frame = self.elevatorLayer.bounds
        self.doorLayer.bounds.size.width = 0
        
        for (level, floor) in floors.enumerated() {
            floor.frame = floorFrame(at: level)
        }
    }
    
    func floorFrame(at floor: Int) -> CGRect {
        let numberOfFloors = CGFloat(self.numberOfFloors)
        let floorSize = CGSize(width: frame.width, height: frame.height / numberOfFloors)
        
        return CGRect(
            x: 0,
            y: floorSize.height * (numberOfFloors - CGFloat(floor) - 1),
            width: floorSize.width,
            height: floorSize.height
        )
    }
}

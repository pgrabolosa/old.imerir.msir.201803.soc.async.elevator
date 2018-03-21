import UIKit

public class ElevatorView : UIView, ElevatorObserver {
    
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
        self.elevatorLayer.backgroundColor = UIColor.cyan.cgColor
        self.doorLayer.backgroundColor = UIColor.darkGray.cgColor
        self.elevatorLayer.addSublayer(self.doorLayer)
        self.layer.addSublayer(elevatorLayer)
        
        onLoadToken = self.elevator.observe(\Elevator.load) { (elevator, change) in
            if self.passengers.count > elevator.load {
                self.removePassenger()
            } else if self.passengers.count < elevator.load {
                self.addPassenger()
            }
        }
        
        onStateToken = self.elevator.observe(\Elevator.state) { (elevator, change) in
            switch elevator.state {
            case .idle:
                self.closedDoors()
            case .opened:
                self.openedDoors()
            case .opening:
                self.openingDoors()
            case .closing:
                self.closingDoors()
            case .movingDown:
                break
            case .movingUp:
                break
            }
        }
        
        onFloorToken = self.elevator.observe(\Elevator.state) { (elevator, change) in
            self.moveToCurrentFloor()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removePassenger() {
        DispatchQueue.main.async {
            self.passengers.removeLast().removeFromSuperlayer()
        }
    }
    
    func addPassenger() {
        DispatchQueue.main.async {
            let newPassenger = CALayer()
            newPassenger.frame = CGRect(origin: CGPoint(x: CGFloat(5 + ((25+5) * self.passengers.count)) , y: (self.elevatorLayer.bounds.height - 25)/2), size: CGSize(width: 25, height: 25))
            newPassenger.backgroundColor = UIColor.black.cgColor
            self.passengers.append(newPassenger)
            self.elevatorLayer.addSublayer(newPassenger)
        }
    }
    
    func closedDoors() {
        DispatchQueue.main.async {
            self.doorLayer.frame = self.elevatorLayer.bounds
        }
    }
    
    func closingDoors() {
        DispatchQueue.main.async {
            self.doorLayer.frame = self.elevatorLayer.bounds
        }
    }
    
    func openedDoors() {
        DispatchQueue.main.async {
            self.doorLayer.bounds.size.height = 0
        }
            
    }
    
    func openingDoors() {
        DispatchQueue.main.async {
            self.doorLayer.bounds.size.height = 0
        }
    }
    
    func moveToCurrentFloor() {
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setAnimationDuration(2)
            
            let newLevel = self.elevator.currentFloor
            self.elevatorLayer.frame = self.floors[newLevel].frame
            
            CATransaction.commit()
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

//
//  ElevatorRx.swift
//  Elevator
//
//  Created by Pierre Grabolosa on 22/03/2018.
//  Copyright © 2018 Pierre Grabolosa. All rights reserved.
//

import RxSwift

public class ElevatorRx : ElevatorObserver {
    let elevator: Elevator
    var currentFloor: Variable<Int>
    var state: Variable<ElevatorState>
    
    init(elevator: Elevator) {
        self.elevator = elevator
        currentFloor = Variable(elevator.currentFloor)
        state = Variable(elevator.state)
        
        elevator.observers.append(self)
    }
    
    public func elevator(_ elevator: Elevator, didChangeFloorFrom from: Int, to: Int) {
        currentFloor.value = to
    }
}

extension Elevator {
    var rx : ElevatorRx {
        return ElevatorRx(elevator: self)
    }
}

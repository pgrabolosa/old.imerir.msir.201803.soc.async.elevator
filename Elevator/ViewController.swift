//
//  ViewController.swift
//  Elevator
//
//  Created by Pierre Grabolosa on 18/03/2018.
//  Copyright © 2018 Pierre Grabolosa. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController, ElevatorObserver {
    
    let numberOfElevators = 5
    var elevators: [Elevator] = []
    var target: [Elevator:Int] = [:]
    
    func update(_ elevator: Elevator) {
        let target = self.target[elevator]!
        
        if elevator.state == .opened {
            elevator.closeDoors().then { self.update(elevator) }
        } else if elevator.currentFloor == target {
            elevator.openDoors()
        } else if elevator.currentFloor > target {
            elevator.move(.down).then { self.update(elevator) }
        } else if elevator.currentFloor < target {
            elevator.move(.up).then { self.update(elevator) }.onError {
                print("Reached heaven… or hell?!")
            }
        }
    }
    
    var sameFloorSubscription: Disposable?
    
    override func loadView() {
        var views = [ElevatorView]()
        elevators = []
        
        for _ in 0..<numberOfElevators {
            let e = Elevator()
            let v = ElevatorView(e)
            
            v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
            
            elevators.append(e)
            views.append(v)
        }
        
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        
        sameFloorSubscription = Observable.combineLatest(
            elevators.map { $0.rx.currentFloor.asObservable() }
        ).map { (floors: [Int]) -> Int? in
            let reference = floors.first!
            for floor in floors {
                if floor != reference {
                    return nil
                }
            }
            return reference
        }.distinctUntilChanged { $0 == $1 }.subscribe(onNext: { value in
            if let floor = value {
                print("Same floor: \(floor)")
            } else {
                print("Not the same floor")
            }
        })
        
        self.view = stack
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view as? ElevatorView else {
            return
        }
        let elevator = view.elevator
        
        let ac = UIAlertController(title: "Call", message: "To which floor?", preferredStyle: .alert)
        
        ac.addTextField { $0.placeholder = "Floor number" }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Go", style: .default, handler: { _ in
            self.target[elevator] = Int(ac.textFields![0].text!)!
            self.update(elevator)
        }))
        
        present(ac, animated: true, completion: nil)
    }
    
    /*
    func elevator(_ elevator: Elevator, didChangeFloorFrom from: Int, to: Int) {
        update()
    }
    
    func elevatorDidCloseDoor(_ elevator: Elevator) {
        update()
    }
    
    func elevatorDidOpenDoor(_ elevator: Elevator) {
        print("Reached destination")
    }
     */
}


//
//  ViewController.swift
//  Elevator
//
//  Created by Pierre Grabolosa on 18/03/2018.
//  Copyright © 2018 Pierre Grabolosa. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ElevatorObserver {
    
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
    
    override func loadView() {
        let left = ElevatorView(Elevator())
        let right = ElevatorView(Elevator())
        let stack = UIStackView(arrangedSubviews: [left, right])
        
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        
        self.view = stack
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leftElevatorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        rightElevatorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        let elevator: Elevator
        if sender.view === leftElevatorView {
            elevator = leftElevator
        } else {
            elevator = rightElevator
        }
        
        let ac = UIAlertController(title: "Call", message: "To which floor?", preferredStyle: .alert)
        
        ac.addTextField { $0.placeholder = "Floor number" }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Go", style: .default, handler: { _ in
            self.target[elevator] = Int(ac.textFields![0].text!)!
            self.update(elevator)
        }))
        
        present(ac, animated: true, completion: nil)
    }
    
    var leftElevatorView: ElevatorView { return (self.view as! UIStackView).arrangedSubviews[0] as! ElevatorView }
    var leftElevator : Elevator { return self.leftElevatorView.elevator }
    
    var rightElevatorView: ElevatorView { return (self.view as! UIStackView).arrangedSubviews[1] as! ElevatorView }
    var rightElevator : Elevator { return self.rightElevatorView.elevator }
    
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


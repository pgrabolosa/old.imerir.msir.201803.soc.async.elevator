//
//  ViewController.swift
//  Elevator
//
//  Created by Pierre Grabolosa on 18/03/2018.
//  Copyright © 2018 Pierre Grabolosa. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ElevatorObserver {
    
    var target = 3
    
    func update() {
        if elevator.state == .opened {
            elevator.closeDoors().then(update)
        } else if elevator.currentFloor == target {
            elevator.openDoors()
        } else if elevator.currentFloor > target {
            elevator.move(.down).then(update)
        } else if elevator.currentFloor < target {
            elevator.move(.up).then(update).onError {
                print("Reached heaven")
            }
        }
    }
    
    override func loadView() {
        self.view = ElevatorView(Elevator())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    @objc func tapped() {
        let ac = UIAlertController(title: "Call", message: "To which floor?", preferredStyle: .alert)
        
        ac.addTextField { $0.placeholder = "Floor number" }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Go", style: .default, handler: { _ in
            self.target = Int(ac.textFields![0].text!)!
            self.update()
        }))
        
        present(ac, animated: true, completion: nil)
    }
    
    var elevatorView: ElevatorView { return self.view as! ElevatorView }
    var elevator : Elevator { return self.elevatorView.elevator }
    
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


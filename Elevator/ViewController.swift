//
//  ViewController.swift
//  Elevator
//
//  Created by Pierre Grabolosa on 18/03/2018.
//  Copyright © 2018 Pierre Grabolosa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let elevator = Elevator()
    let op = OperationQueue()
    
//    func moveUp() -> Promise {
//        let p = Promise()
//
//        op.addOperation {
//            try! self.elevator.move(.up)
//            self.elevator.waitForIdle()
//            p.resolve(as: .success)
//        }
//
//        return p
//    }


    override func loadView() {
        self.view = ElevatorView(elevator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

         op.addOperation {
             try! self.elevator.move(.up)
             self.elevator.waitForIdle()
             try! self.elevator.openDoors()
             self.elevator.waitForIdle()
             try! self.elevator.loadPassengers(3)
             try! self.elevator.closeDoors()
             self.elevator.waitForIdle()
             try! self.elevator.move(.up)
             self.elevator.waitForIdle()
             try! self.elevator.openDoors()
             self.elevator.waitForIdle()
             try! self.elevator.unloadPassengers(3)
             self.elevator.waitForIdle()
             try! self.elevator.closeDoors()
             self.elevator.waitForIdle()
         }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  ViewController.swift
//  FindVR
//
//  Created by Ioana Bostan on 11.12.2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func startChallengeAction(_ sender: Any) {
        print("Start clicked")
        
        self.performSegue(withIdentifier: "solveChallenge", sender: self)
    }
    @IBAction func createChallengeAction(_ sender: Any) {
        print("Create clicked")
        self.performSegue(withIdentifier: "createChallenge", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "solveChallenge" {
            if let destinationVC = segue.destination as? arViewController {
                destinationVC.showSolveChallenge = true
                destinationVC.viewController = self

            }
        }
        if segue.identifier == "createChallenge" {
            if let destinationVC = segue.destination as? createChallengeViewController {
                destinationVC.viewController = self

            }
        }
    }
}


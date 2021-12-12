//
//  ViewController.swift
//  FindVR
//
//  Created by Ioana Bostan on 11.12.2021.
//

import UIKit

class chooseClueViewController: UIViewController {

    var arView: arViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ((arView) != nil) {
            arView.dismiss(animated: false, completion: nil)
        }
    }

    @IBAction func startButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "clueAndSolve", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "clueAndSolve" {
            if let destinationVC = segue.destination as? arViewController {
                destinationVC.showSolveChallenge = true
                destinationVC.chooseClue = self
            }
        }
    }
}


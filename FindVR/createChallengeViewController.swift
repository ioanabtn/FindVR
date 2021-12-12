//
//  createChallengeViewController.swift
//  FindVR
//
//  Created by Ioana Bostan on 11.12.2021.
//
import UIKit
import Foundation

let userDefaults = UserDefaults.standard

class createChallengeViewController: UIViewController {

    var viewController: ViewController!
//    var item = "cup_saucer_set";
    override func viewDidLoad() {
        
        if ((viewController) != nil) {
            viewController.dismiss(animated: false, completion: nil)
        }

        super.viewDidLoad()
        userDefaults.set("cup_saucer_set", forKey: "item")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func teapotTapped(_ sender: Any) {
        userDefaults.set("teapot", forKey: "item")
        self.performSegue(withIdentifier: "placeObject", sender: self)
    }
    
    @IBAction func shoeTapped(_ sender: Any) {
        userDefaults.set("shoe", forKey: "item")
        self.performSegue(withIdentifier: "placeObject", sender: self)
    }
    
    @IBAction func cupTapped(_ sender: Any) {
        userDefaults.set("cup_saucer_set", forKey: "item")
        self.performSegue(withIdentifier: "placeObject", sender: self)
    }
    
    @IBAction func chairTapped(_ sender: Any) {
        userDefaults.set("chair_swan", forKey: "item")
        self.performSegue(withIdentifier: "placeObject", sender: self)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "placeObject" {
            if let destinationVC = segue.destination as? arViewController {
                destinationVC.createChallenge = self
            }
        }
    }
}


//
//  arViewController.swift
//  FindVR
//
//  Created by Ioana Bostan on 11.12.2021.
//

import UIKit
import RealityKit
import ARKit
import Foundation

class arViewController: UIViewController {

    @IBOutlet weak var arView: ARView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    var showSolveChallenge = false
    var item = "cup_saucer_set"
    var chooseClue: chooseClueViewController!
    var createChallenge: createChallengeViewController!
    var viewController: ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if ((chooseClue) != nil) {
            chooseClue.dismiss(animated: false, completion: nil)
        }
        
        if ((createChallenge) != nil) {
            createChallenge.dismiss(animated: false, completion: nil)
        }
            
        if ((viewController) != nil) {
            print("dismiss view controller")
            viewController.dismiss(animated: false, completion: nil)
        }
            
        if let itemString = UserDefaults.standard.value(forKey: "item") as? String {
            self.item = itemString
        }
     
        // Do any additional setup after loading the view.
        self.startButton.isHidden = true
        // Show the "Load Challenge" button only if this view was loaded in the Solve mode
        if (showSolveChallenge) {
            self.saveButton.isHidden = true
            self.startButton.isHidden = true
        }
    }
    
    @IBAction func startChallengeAction(_ sender: Any) {
        self.performSegue(withIdentifier: "clue", sender: self)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        arView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { print("Can't get current world map"); return }
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                try data.write(to: self.mapSaveURL, options: [.atomic])
                DispatchQueue.main.async {
                    self.saveButton.isHidden = true // hide the save button
                    self.startButton.isHidden = false
                }
            } catch {
                fatalError("Can't save map: \(error.localizedDescription)")
            }
        }
    }
    
    
    func loadChallenge() {
        /// - Tag: ReadWorldMap
        let worldMap: ARWorldMap = {
            guard let data = mapDataFromFile
                else { fatalError("Map data should already be verified to exist before Load button is enabled.") }
            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
                    else { fatalError("No ARWorldMap in archive.") }
                return worldMap
            } catch {
                fatalError("Can't unarchive ARWorldMap from file data: \(error)")
            }
        }()
        
        let configuration = self.defaultConfiguration // this app's standard world tracking settings
        configuration.initialWorldMap = worldMap
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - AR session management
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        return configuration
    }
    
    // Called opportunistically to verify that map data can be loaded from filesystem.
    var mapDataFromFile: Data? {
        return try? Data(contentsOf: mapSaveURL)
    }
    
    lazy var mapSaveURL: URL = {
        do {
            return try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent("map.arexperience")
        } catch {
            fatalError("Can't get file save URL: \(error.localizedDescription)")
        }
    }()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self

        setupARView()

        if (!showSolveChallenge) {
            arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
        }
        
        // Show the "Load Challenge" button only if this view was loaded in the Solve mode
        if (showSolveChallenge) {
            loadChallenge()
        }
    }
    

    func setupARView() {

        arView.environment.sceneUnderstanding.options.insert(.receivesLighting)
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        // devices with lidar sensors only
        // configuration.sceneReconstruction = .meshWithClassification
        // people occlusion
        configuration.frameSemantics.insert(.personSegmentationWithDepth)
        arView.session.run(configuration)
    }

    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: item, transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("We couldn't find a surface")
        }
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "clue" {
            if let destinationVC = segue.destination as? chooseClueViewController {
                destinationVC.arView = self
            }
        }
    }
}


extension arViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == item {
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}

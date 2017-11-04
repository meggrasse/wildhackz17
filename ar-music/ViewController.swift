//
//  ViewController.swift
//  ar-music
//
//  Created by Meg on 11/4/17.
//  Copyright © 2017 wildhackz17. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MediaPlayer
import CoreLocation
import ARCL

class ViewController: UIViewController, ARSCNViewDelegate {
    //set up what a musicData is (spoiler: it's time + song + location)
    struct MusicData {
        var time : Date?
        var song : MPMediaItem?
        var location : CLLocationCoordinate2D?

        init(time nowTime : Date?, song nowSong : MPMediaItem?, location nowLocation : CLLocationCoordinate2D?){
            time = nowTime
            song = nowSong
            location = nowLocation
        }
    }

    var musicHistory = [MusicData]()
    let locationManager = CLLocationManager()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        // when the view loads, begin checking for when the song changes
        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(trackChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //when the view appears, get location authorization
        switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                // Request when-in-use authorization initially
                locationManager.requestWhenInUseAuthorization()
                break
            case .restricted, .denied:
                print("User denied location request")
                break
            case .authorizedWhenInUse, .authorizedAlways:
                break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func trackChanged() {
        let nowPlaying = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
        let artwork = nowPlaying?.artwork?.image(at: CGSize(width: 50, height: 50))
        let coordinates = locationManager.location?.coordinate
        if let nowPlayingItem = nowPlaying {
            let data = MusicData(time : Date(), song : nowPlayingItem, location : coordinates)
            musicHistory.append(data)
        }

        let scene = SCNScene()
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)

        // add artwork as material for box
        let material = SCNMaterial()
        material.diffuse.contents = artwork
        box.firstMaterial = material

        let node = SCNNode(geometry: box)

        // place right in front of camera
        node.position = SCNVector3Make(0, 0, -0.5);

        scene.rootNode.addChildNode(node)

        sceneView.scene = scene
    }
}

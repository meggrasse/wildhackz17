//
//  ViewController.swift
//  music-map
//
//  Created by Meg on 11/3/17.
//  Copyright © 2017 wildhackz17. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    
    var trackLocationDict = [MPMediaItem:CLLocationCoordinate2D]()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(trackChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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

    @objc func trackChanged() {
        let nowPlaying = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
        
        let coordinates = locationManager.location?.coordinate
        if let nowPlayingItem = nowPlaying{
            trackLocationDict[nowPlayingItem] = coordinates
        }
    }
}


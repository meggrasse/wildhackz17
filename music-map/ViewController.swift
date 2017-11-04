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

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var label: UILabel!
    
    var trackLocationDict = [MPMediaItem:CLLocation]()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        label.text = "Hello World"
//
        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(trackChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                // Request when-in-use authorization initially
                locationManager.requestWhenInUseAuthorization()
                break
            
            case .restricted, .denied:
                break
            
            case .authorizedWhenInUse, .authorizedAlways:
                break
            }
    }

    @objc func trackChanged() {
        print ("The track changed")
        let nowPlaying = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
        locationManager.requestLocation()
        
        
        if let nowPlayingItem = nowPlaying {
            trackLocationDict[nowPlayingItem] = nil
        }
        print(trackLocationDict)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]){
        print ("Got location")
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("failing")
    }
}


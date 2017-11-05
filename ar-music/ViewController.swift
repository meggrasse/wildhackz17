//
//  ViewController.swift
//  ar-music
//
//  Created by Meg on 11/4/17.
//  Copyright © 2017 wildhackz17. All rights reserved.
//

import UIKit
import MediaPlayer
import ARKit
import CoreLocation
import ARCL

class ViewController: UIViewController {
    
    //set up what a musicData is (spoiler: it's time + song + location)
    struct MusicData {
        var time : Date?
        var song : MPMediaItem?
        var location : CLLocation?

        init(time nowTime : Date?, song nowSong : MPMediaItem?, location nowLocation : CLLocation?){
            time = nowTime
            song = nowSong
            location = nowLocation
        }
    }

    var musicHistory = [MusicData]()
    let locationManager = CLLocationManager()

    var sceneLocationView = SceneLocationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        sceneLocationView.frame = view.bounds

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
    
    @objc func trackChanged() {
        let nowPlaying = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
        let artwork = nowPlaying?.artwork?.image(at: CGSize(width: 5, height: 5))
        let location = locationManager.location
        if let nowPlayingItem = nowPlaying {
            let data = MusicData(time : Date(), song : nowPlayingItem, location : location)
            musicHistory.append(data)
        }
        
        if let userLocation = musicHistory.last?.location {
            if let realArtwork = artwork {
                let locationAnnotationBox = LocationAnnotationBox(location: userLocation, image: realArtwork)
                self.addLocationNode(locationNode: locationAnnotationBox)
            }
        }
    }
        
    func addLocationNode(locationNode: LocationNode) {
        guard let currentPosition = sceneLocationView.currentScenePosition(),
            let _ = locationNode.location,
            let sceneNode = sceneLocationView.sceneNode else {
                return
        }
        
        locationNode.position = currentPosition
        sceneNode.addChildNode(locationNode)
    }
}

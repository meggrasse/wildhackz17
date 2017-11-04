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
    
    //set up what a musicData is (spoiler: it's time + song + location)
    struct MusicData {
        var time : Date?
        var song : MPMediaItem?
        var location : CLLocationCoordinate2D?
        init(){
            time = nil
            song  = nil
            location = nil
        }
        init(time nowTime : Date?, song nowSong : MPMediaItem?, location nowLocation : CLLocationCoordinate2D?){
            time = nowTime
            song = nowSong
            location = nowLocation
        }
    }
    var musicDatas = [MusicData]()
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        //when the view loads, begin checking for when the song changes
        super.viewDidLoad()
        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(trackChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        
        //when the view loads, begin an AR session
        
    }
    
    //when the view appears, get location authorization
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
    
    //when the track changes, record the time, song, and location
    @objc func trackChanged() {
        let nowPlaying = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
        let coordinates = locationManager.location?.coordinate
        if let nowPlayingItem = nowPlaying{
            let data = MusicData(time : Date(), song : nowPlayingItem, location : coordinates)
            musicDatas.append(data)
        }
    }
}


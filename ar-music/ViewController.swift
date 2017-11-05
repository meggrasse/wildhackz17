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
    var nodeHistoryDict = [SCNGeometry: MusicData]()
    
    let locationManager = CLLocationManager()
    var sceneLocationView = SceneLocationView()
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        sceneLocationView.frame = view.bounds
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(albumTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        label.numberOfLines = 3
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        label.frame.origin = CGPoint(x: 0, y: self.view.bounds.maxY - 75)
        label.frame.size = CGSize(width: self.view.frame.width, height: 75)
        label.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.4)
        label.textAlignment = .center
        label.layer.masksToBounds = true;
        label.layer.cornerRadius = 8.0;
        self.view.addSubview(label)
        
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
            if let realArtwork = artwork {
                let locationAnnotationBox = LocationAnnotationBox(location: location, image: realArtwork)
                self.addLocationNode(locationNode: locationAnnotationBox)
                if let geometry = locationAnnotationBox.childNodes[0].geometry {
                    nodeHistoryDict[geometry] = data
                }
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
    
    @objc func albumTap(_ recognizer: UITapGestureRecognizer){
        let touchCoordinates = recognizer.location(in: sceneLocationView)
        let sceneHitTestResult = sceneLocationView.hitTest(touchCoordinates, options: nil)
        for results in sceneHitTestResult {
            if let geo = results.node.geometry {
                let data = nodeHistoryDict[geo]
                if let title = data?.song?.title, let artist = data?.song?.artist, let album = data?.song?.albumTitle, let time = data?.time {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy 'at' HH:mm"
                        let dateString: String = dateFormatter.string(from: time)
                        let labelText = title + "\n" + artist + " — " + album + "\n" + dateString
                        self.label.text = labelText
                }
            }
        }
    }
}

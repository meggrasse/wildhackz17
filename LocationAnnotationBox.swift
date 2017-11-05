//
//  LocationAnnotationBox.swift
//  ar-music
//
//  Created by Meg on 11/4/17.
//  Copyright © 2017 wildhackz17. All rights reserved.
//

import UIKit
import SceneKit
import CoreLocation
import ARCL

class LocationAnnotationBox: LocationNode {
    
    let annotationBoxNode : SCNNode
    let image : UIImage
    
    init(location: CLLocation?, image: UIImage) {
        self.image = image
        
        let box = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.01)
       
        let material = SCNMaterial()
        material.diffuse.contents = image
        box.firstMaterial = material
        
        self.annotationBoxNode = SCNNode()
        self.annotationBoxNode.geometry = box
        
        super.init(location: location)
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]
        
        addChildNode(annotationBoxNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

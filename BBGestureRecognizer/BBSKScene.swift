//
//  BBSKScene.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/26/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit
import Foundation
import UIKit

class BBSKScene: SKScene {
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
//        println("touchesBegan in scene")
        
        // Deliver new touches to all possible gesture recognizers
        if event.type == .Touches {
            
            // If there are any touches
            if let touches = event.allTouches() {
                
                if touches.count > 0 {
                    
                    for touch in touches.allObjects as [UITouch] {
                        
                        // Send the touch to all gesture recognizers on the 
                        // deepest node that intersects this touch's location
                        let deepestNode = nodeAtPoint(touch.locationInNode(self))
                        
                        
                        for node in nodesAtPoint(touch.locationInNode(self)) {
                            println("node at point: \(node)")
                        }
//                        for descendant in descendants {
//                            let descendantPoint =
//                            if descendant.containsPoint(descendantPoint) {
//                                println("point contained")
//                            }
//                        }
                    }
                }
            }
            
            // Iterate over all touches
//            for touch in touches {
//
//                // Iterate over all child nodes in scene
//                for node in children
//            }
        }
    }
}

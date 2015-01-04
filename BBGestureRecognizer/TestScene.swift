//
//  TestScene.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/26/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

class TestScene: SKScene {
    
    var singleTapRecognizer: BBUITapGestureRecognizer!
    var doubleTapRecognizer: BBUITapGestureRecognizer!
    
    override func didMoveToView(view: SKView) {
        
        let midX = CGRectGetMidX(self.frame)
        let midY = CGRectGetMidY(self.frame)
        
        // Create a node
        
        let nodeB = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(500, 500))
        nodeB.position = CGPointMake(midX, midY)
        nodeB.name = "nodeB"
        nodeB.userInteractionEnabled = true
        
        println("recognizers: \(nodeB.gestureRecognizers)")
        singleTapRecognizer = BBUITapGestureRecognizer(target: self, action: TestScene.handleSingleTap)
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.numberOfTouchesRequired = 2
        singleTapRecognizer.name = "Single Tap Recognizer"
        doubleTapRecognizer = BBUITapGestureRecognizer(target: self, action: TestScene.handleDoubleTap)
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.name = "Double Tap Recognizer"
        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        doubleTapRecognizer.requireGestureRecognizerToFail(singleTapRecognizer)
        nodeB.addGestureRecognizer(singleTapRecognizer)
        nodeB.addGestureRecognizer(doubleTapRecognizer)

        addChild(nodeB)
    }
    
    func handleSingleTap(gestureRecognizer: BBUIGestureRecognizer?) {
//        if gestureRecognizer?.state == BBUIGestureRecognizerState.Ended {
            println("single tap")
            println("\tsingle tap recognizer state: \(singleTapRecognizer.state)")
            println("\tdouble tap recognizer state: \(doubleTapRecognizer.state)")
//        }
    }
    
    func handleDoubleTap(gestureRecognizer: BBUIGestureRecognizer?) {
//        if gestureRecognizer?.state == BBUIGestureRecognizerState.Ended {
        println("double tap")
        println("\tsingle tap recognizer state: \(singleTapRecognizer.state)")
        println("\tdouble tap recognizer state: \(doubleTapRecognizer.state)")
//        println("double tap handler; state: \(doubleTapRecognizer.state)")
//        }
    }
}

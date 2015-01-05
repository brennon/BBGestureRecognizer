//
//  TestScene.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/26/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

class TestScene: SKScene {
    
    var singleTapRecognizer: BBTapGestureRecognizer!
    var doubleTapRecognizer: BBTapGestureRecognizer!
    var panRecognizer: BBPanGestureRecognizer!
    var spriteNode: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        
        let midX = CGRectGetMidX(self.frame)
        let midY = CGRectGetMidY(self.frame)
        
        // Create a node
        
        spriteNode = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(500, 500))
        spriteNode.position = CGPointMake(midX, midY)
        spriteNode.name = "nodeB"
        spriteNode.userInteractionEnabled = true
        
        singleTapRecognizer = BBTapGestureRecognizer(target: self, action: TestScene.handleSingleTap)
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.numberOfTouchesRequired = 2
        singleTapRecognizer.name = "Single Tap Recognizer"
        doubleTapRecognizer = BBTapGestureRecognizer(target: self, action: TestScene.handleDoubleTap)
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.name = "Double Tap Recognizer"
        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        doubleTapRecognizer.requireGestureRecognizerToFail(singleTapRecognizer)
        
        panRecognizer = BBPanGestureRecognizer(target: self, action: TestScene.handlePan)
        
        spriteNode.addGestureRecognizer(singleTapRecognizer)
        spriteNode.addGestureRecognizer(doubleTapRecognizer)
        spriteNode.addGestureRecognizer(panRecognizer)

        addChild(spriteNode)
    }
    
    func handleSingleTap(gestureRecognizer: BBGestureRecognizer?) {
        println("single tap")
        println("\tsingle tap recognizer state: \(singleTapRecognizer.state)")
        println("\tdouble tap recognizer state: \(doubleTapRecognizer.state)")
    }
    
    func handleDoubleTap(gestureRecognizer: BBGestureRecognizer?) {
        println("double tap")
        println("\tsingle tap recognizer state: \(singleTapRecognizer.state)")
        println("\tdouble tap recognizer state: \(doubleTapRecognizer.state)")
    }
    
    func handlePan(gestureRecognizer: BBGestureRecognizer?) {
//        println("pan; translation: \(panRecognizer.translationInNode()), velocity: \(panRecognizer.velocityInNode()))")
        if let recognizer = gestureRecognizer {
            let panRecognizer = recognizer as BBPanGestureRecognizer
            if panRecognizer.state == .Changed {
                let translation = panRecognizer.translationInNode()
                let newPosition = CGPointMake(spriteNode.position.x + translation.x, spriteNode.position.y + translation.y)
                spriteNode.position = newPosition
                panRecognizer.setTranslation(CGPointZero)
            }
        }
    }
}

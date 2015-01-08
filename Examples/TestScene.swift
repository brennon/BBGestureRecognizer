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
    var tapAndAHalfRecognizer: BBTapAndAHalfGestureRecognizer!
    var panRecognizer: BBPanGestureRecognizer!
    var spriteNode: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        
        let midX = CGRectGetMidX(self.frame)
        let midY = CGRectGetMidY(self.frame)
        
        // Create a node
        
        spriteNode = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(100, 100))
        spriteNode.position = CGPointMake(midX, midY)
        spriteNode.name = "nodeB"
        spriteNode.userInteractionEnabled = true
        spriteNode.physicsBody = SKPhysicsBody(rectangleOfSize: spriteNode.size)
        spriteNode.physicsBody?.linearDamping = 10
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        
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
        panRecognizer.requireGestureRecognizerToFail(singleTapRecognizer)
        panRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        panRecognizer.name = "Pan Recognizer"
        
        tapAndAHalfRecognizer = BBTapAndAHalfGestureRecognizer(target: self, action: TestScene.handleTapAndAHalf)
        tapAndAHalfRecognizer.name = "Tap and a Half Recognizer"
//        tapAndAHalfRecognizer.requireGestureRecognizerToFail(singleTapRecognizer)
//        tapAndAHalfRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
//        tapAndAHalfRecognizer.requireGestureRecognizerToFail(panRecognizer)
        
        doubleTapRecognizer.requireGestureRecognizerToFail(panRecognizer)
        
        spriteNode.addGestureRecognizer(singleTapRecognizer)
        spriteNode.addGestureRecognizer(doubleTapRecognizer)
        spriteNode.addGestureRecognizer(panRecognizer)
        spriteNode.addGestureRecognizer(tapAndAHalfRecognizer)

        addChild(spriteNode)
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
    }
    
    func handleSingleTap(gestureRecognizer: BBGestureRecognizer?) {
        println("single tap")
        println("\tsingle tap recognizer state: \(singleTapRecognizer.state)")
        println("\tdouble tap recognizer state: \(doubleTapRecognizer.state)")
    }
    
    func handleDoubleTap(gestureRecognizer: BBGestureRecognizer?) {
        println("double tap")
//        println("\tsingle tap recognizer state: \(singleTapRecognizer.state)")
        println("\tdouble tap recognizer state: \(doubleTapRecognizer.state)")
    }
    
    func handleTapAndAHalf(gestureRecognizer: BBGestureRecognizer?) {
        println("tap and a half")
    }
    
    func handlePan(gestureRecognizer: BBGestureRecognizer?) {
        if let recognizer = gestureRecognizer {
            let panRecognizer = recognizer as BBPanGestureRecognizer
            spriteNode.physicsBody?.velocity = CGVectorMake(0, 0)
            if panRecognizer.state == .Changed {
                let velocity = panRecognizer.velocityInNode(self)
                let translation = panRecognizer.translationInNode(self)
                let newPosition = CGPointMake(spriteNode.position.x + translation.x, spriteNode.position.y + translation.y)
                spriteNode.position = newPosition
                panRecognizer.setTranslation(CGPointZero, inNode: self)
            } else if panRecognizer.state == .Ended {
                let velocity = panRecognizer.velocityInNode(self)
                spriteNode.physicsBody?.velocity = CGVectorMake(0, 0)
                spriteNode.physicsBody?.applyImpulse(CGVectorMake(velocity.x, velocity.y))
            }
        }
    }
}

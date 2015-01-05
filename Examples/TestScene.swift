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
        
        spriteNode.addGestureRecognizer(singleTapRecognizer)
        spriteNode.addGestureRecognizer(doubleTapRecognizer)
        spriteNode.addGestureRecognizer(panRecognizer)

        addChild(spriteNode)
        
        println("convert (0,0) to scene from sprite: \(spriteNode.convertPoint(CGPointZero, toNode: self))")
        println("convert (0,0) from sprite to scene: \(self.convertPoint(CGPointZero, fromNode: spriteNode))")
        println("convert (100,0) to scene from sprite: \(spriteNode.convertPoint(CGPointMake(100, 0), toNode: self))")
        println("convert (100,0) from sprite to scene: \(self.convertPoint(CGPointMake(100, 0), fromNode: spriteNode))")
        println("convert (0,100) to scene from sprite: \(spriteNode.convertPoint(CGPointMake(0, 100), toNode: self))")
        println("convert (0,100) from sprite to scene: \(self.convertPoint(CGPointMake(0, 100), fromNode: spriteNode))")
        println("convert (0,-100) to scene from sprite: \(spriteNode.convertPoint(CGPointMake(0, -100), toNode: self))")
        println("convert (0,-100) from sprite to scene: \(self.convertPoint(CGPointMake(0, -100), fromNode: spriteNode))")
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

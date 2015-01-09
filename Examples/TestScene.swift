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
    var singleTapDoubleTouchRecognizer: BBTapGestureRecognizer!
    var doubleTapRecognizer: BBTapGestureRecognizer!
    var tapAndAHalfRecognizer: BBTapAndAHalfGestureRecognizer!
    var tapTapDragRecognizer: BBTapTapDragGestureRecognizer!
    var panRecognizer: BBPanGestureRecognizer!
    var spriteNode: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        
        // Setup scene
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        
        // Create a node
        let midX = CGRectGetMidX(self.frame)
        let midY = CGRectGetMidY(self.frame)
        spriteNode = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(200, 200))
        spriteNode.position = CGPointMake(midX, midY)
        spriteNode.name = "nodeB"
        spriteNode.userInteractionEnabled = true
        spriteNode.physicsBody = SKPhysicsBody(rectangleOfSize: spriteNode.size)
        spriteNode.physicsBody?.linearDamping = 5
        
        // Setup recognizers
        singleTapRecognizer = BBTapGestureRecognizer(target: self, action: TestScene.handleSingleTap)
        singleTapRecognizer.name = "Single Tap Recognizer"
        
        singleTapDoubleTouchRecognizer = BBTapGestureRecognizer(target: self, action: TestScene.handleSingleTapDoubleTouch)
        singleTapDoubleTouchRecognizer.numberOfTouchesRequired = 2
        singleTapDoubleTouchRecognizer.name = "Two Finger Single Tap Recognizer"
        
        doubleTapRecognizer = BBTapGestureRecognizer(target: self, action: TestScene.handleDoubleTap)
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.name = "Double Tap Recognizer"
        
        panRecognizer = BBPanGestureRecognizer(target: self, action: TestScene.handlePan)
        panRecognizer.name = "Pan Recognizer"
        
        tapTapDragRecognizer = BBTapTapDragGestureRecognizer(target: self, action: TestScene.handleTapTapDrag)
        tapTapDragRecognizer.name = "Tap Tap Drag Recognizer"
        
        tapAndAHalfRecognizer = BBTapAndAHalfGestureRecognizer(target: self, action: TestScene.handleTapAndAHalf)
        tapAndAHalfRecognizer.name = "Tap and a Half Recognizer"
        
        // Add recognizers to node
        spriteNode.addGestureRecognizer(singleTapRecognizer)
        spriteNode.addGestureRecognizer(doubleTapRecognizer)
        spriteNode.addGestureRecognizer(singleTapDoubleTouchRecognizer)
        spriteNode.addGestureRecognizer(tapAndAHalfRecognizer)
        spriteNode.addGestureRecognizer(tapTapDragRecognizer)
        spriteNode.addGestureRecognizer(panRecognizer)
        
        // Setup dependencies
        tapTapDragRecognizer.requireGestureRecognizerToFail(panRecognizer)
        tapTapDragRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        panRecognizer.requireGestureRecognizerToFail(tapTapDragRecognizer)

        addChild(spriteNode)
    }
    
    func handleSingleTap(gestureRecognizer: BBGestureRecognizer?) {
        if let recognizer = gestureRecognizer {
            let tapRecognizer = recognizer as BBTapGestureRecognizer
            if tapRecognizer.state == .Recognized {
                flashLabel("Single Tap")
            }
        }
    }
    
    func handleSingleTapDoubleTouch(gestureRecognizer: BBGestureRecognizer?) {
        if let recognizer = gestureRecognizer {
            let tapRecognizer = recognizer as BBTapGestureRecognizer
            if tapRecognizer.state == .Recognized {
                flashLabel("Two Finger Single Tap")
            }
        }
    }
    
    func handleDoubleTap(gestureRecognizer: BBGestureRecognizer?) {
        if let recognizer = gestureRecognizer {
            let tapRecognizer = recognizer as BBTapGestureRecognizer
            if tapRecognizer.state == .Recognized {
                flashLabel("Double Tap")
            }
        }
    }
    
    func handleTapAndAHalf(gestureRecognizer: BBGestureRecognizer?) {
        if let recognizer = gestureRecognizer {
            let tapTapDragRecognizer = recognizer as BBTapAndAHalfGestureRecognizer
            if tapTapDragRecognizer.state == .Recognized {
                flashLabel("Tap and a Half")
            }
        }
    }
    
    func handleTapTapDrag(gestureRecognizer: BBGestureRecognizer?) {
        if let recognizer = gestureRecognizer {
            let tapTapDragRecognizer = recognizer as BBTapTapDragGestureRecognizer
            spriteNode.physicsBody?.velocity = CGVectorMake(0, 0)
            if tapTapDragRecognizer.state == .Changed {
                let velocity = tapTapDragRecognizer.velocityInNode(self)
                let translation = tapTapDragRecognizer.translationInNode(self)
                let newPosition = CGPointMake(spriteNode.position.x + translation.x, spriteNode.position.y + translation.y)
                spriteNode.position = newPosition
                tapTapDragRecognizer.setTranslation(CGPointZero, inNode: self)
            } else if tapTapDragRecognizer.state == .Ended {
                flashLabel("Tap and a Half + Drag")
                let velocity = tapTapDragRecognizer.velocityInNode(self)
                spriteNode.physicsBody?.velocity = CGVectorMake(0, 0)
                spriteNode.physicsBody?.applyImpulse(CGVectorMake(velocity.x, velocity.y))
            }
        }
    }
    
    func handlePan(gestureRecognizer: BBGestureRecognizer?) {
        if let recognizer = gestureRecognizer {
            let panRecognizer = recognizer as BBPanGestureRecognizer
            spriteNode.physicsBody?.velocity = CGVectorMake(0, 0)
            if panRecognizer.state == .Began {
                flashLabel("Pan")
            } else if panRecognizer.state == .Changed {
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
    
    func flashLabel(text: String) {
        let labelNode = SKLabelNode(text: text)
        labelNode.fontSize = 72
        labelNode.fontColor = UIColor.whiteColor()
        labelNode.position = CGPointMake(size.width / 2, size.height + labelNode.fontSize)
        labelNode.alpha = 0
        addChild(labelNode)
        
        let fadeIn = SKAction.fadeInWithDuration(0.2)
        let slideUp = SKAction.moveTo(CGPointMake(size.width / 2, size.height - labelNode.fontSize - 12), duration: 0.2)
        let fadeInAndSlideUp = SKAction.group([fadeIn, slideUp])
        
        let wait = SKAction.waitForDuration(0.3)
        let fadeOut = SKAction.fadeOutWithDuration(0.1)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeInAndSlideUp, wait, fadeOut, remove])
        labelNode.runAction(sequence)
    }
}

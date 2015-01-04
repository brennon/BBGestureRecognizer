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
        
        let spriteNode = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(500, 500))
        spriteNode.position = CGPointMake(midX, midY)
        spriteNode.name = "nodeB"
        spriteNode.userInteractionEnabled = true
        
        println("recognizers: \(spriteNode.gestureRecognizers)")
        singleTapRecognizer = BBUITapGestureRecognizer(target: self, action: TestScene.handleSingleTap)
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.numberOfTouchesRequired = 2
        singleTapRecognizer.name = "Single Tap Recognizer"
        doubleTapRecognizer = BBUITapGestureRecognizer(target: self, action: TestScene.handleDoubleTap)
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.name = "Double Tap Recognizer"
        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        doubleTapRecognizer.requireGestureRecognizerToFail(singleTapRecognizer)
        spriteNode.addGestureRecognizer(singleTapRecognizer)
        spriteNode.addGestureRecognizer(doubleTapRecognizer)

        addChild(spriteNode)
    }
    
    func handleSingleTap(gestureRecognizer: BBUIGestureRecognizer?) {
        println("single tap")
        println("\tsingle tap recognizer state: \(singleTapRecognizer.state)")
        println("\tdouble tap recognizer state: \(doubleTapRecognizer.state)")
    }
    
    func handleDoubleTap(gestureRecognizer: BBUIGestureRecognizer?) {
        println("double tap")
        println("\tsingle tap recognizer state: \(singleTapRecognizer.state)")
        println("\tdouble tap recognizer state: \(doubleTapRecognizer.state)")
    }
}

//
//  TestScene.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/26/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

class TestScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        
        let midX = CGRectGetMidX(self.frame)
        let midY = CGRectGetMidY(self.frame)
        
        // Create some nodes
//        let nodeA = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(100, 100))
//        nodeA.position = CGPointMake(midX, midY + 200)
//        nodeA.name = "nodeA"
//        nodeA.userInteractionEnabled = true
        
        let nodeB = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(500, 500))
        nodeB.position = CGPointMake(midX, midY)
        nodeB.name = "nodeB"
        nodeB.userInteractionEnabled = true
        
        println("recognizers: \(nodeB.gestureRecognizers)")
        let recognizer = BBUITapGestureRecognizer(target: self, action: TestScene.doSomething)
        nodeB.addGestureRecognizer(recognizer)
        println("recognizers after adding one: \(nodeB.gestureRecognizers)")
        
//        let nodeC = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(100, 100))
//        nodeC.position = CGPointMake(midX, midY - 200)
//        nodeC.name = "nodeC"
//        nodeC.userInteractionEnabled = true
//        
//        addChild(nodeA)
        addChild(nodeB)
//        addChild(nodeC)
//        
//        let nodeAA = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(100, 100))
//        nodeAA.position = CGPointMake(110, 0)
//        nodeAA.name = "nodeAA"
//        nodeAA.userInteractionEnabled = true
//        
//        nodeA.addChild(nodeAA)
//        
//        let nodeBA = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(100, 100))
//        nodeBA.position = CGPointMake(110, 0)
//        nodeBA.name = "nodeBA"
//        nodeBA.userInteractionEnabled = true
//        
//        let nodeBB = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(100, 100))
//        nodeBB.position = CGPointMake(-110, 0)
//        nodeBB.name = "nodeBB"
//        nodeBB.userInteractionEnabled = true
//        
//        nodeB.addChild(nodeBA)
//        nodeB.addChild(nodeBB)
//        
//        let nodeBAA = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(100, 100))
//        nodeBAA.position = CGPointMake(110, 0)
//        nodeBAA.name = "nodeBAA"
//        nodeBAA.userInteractionEnabled = true
//        
//        nodeBA.addChild(nodeBAA)
//        
//        println("\(descendants)")
//        println("number of descendants: \(descendants.count)")
    }
    
    func doSomething(gestureRecognizer: BBUIGestureRecognizer?) {
        println("tapped!")
    }
}

//
//  TestScene.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/26/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

class TestScene: BBSKScene {
    
    override func didMoveToView(view: SKView) {
        
        let midX = CGRectGetMidX(self.frame)
        let midY = CGRectGetMidY(self.frame)
        
        // Create some nodes
        let nodeA = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(100, 100))
        nodeA.position = CGPointMake(midX, midY + 200)
        
        let nodeB = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(100, 100))
        nodeB.position = CGPointMake(midX, midY)
        
        let nodeC = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(100, 100))
        nodeC.position = CGPointMake(midX, midY - 200)
        
        addChild(nodeA)
        addChild(nodeB)
        addChild(nodeC)
        
        let nodeAA = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(100, 100))
        nodeAA.position = CGPointMake(110, 0)
        
        nodeA.addChild(nodeAA)
        
        let nodeBA = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(100, 100))
        nodeBA.position = CGPointMake(110, 0)
        
        let nodeBB = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(100, 100))
        nodeBB.position = CGPointMake(-110, 0)
        
        nodeB.addChild(nodeBA)
        nodeB.addChild(nodeBB)
        
        let nodeBAA = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(100, 100))
        nodeBAA.position = CGPointMake(110, 0)
        
        nodeBA.addChild(nodeBAA)
        
        println("\(descendants)")
        println("number of descendants: \(descendants.count)")
    }
}

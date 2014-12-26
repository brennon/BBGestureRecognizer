//
//  BBSKNode.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/26/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

extension SKNode {
    var descendants: [SKNode] {
        return _descendants(self)
    }
    
    private func _descendants(node: SKNode) -> [SKNode] {
        
        var descendantsList = [SKNode]()
        
        if node.children.count == 0 {
            return descendantsList
        }
        
        // Iterate over node's chidren
        for child in node.children as [SKNode] {
            
            // Add child to list
            descendantsList += [child]
            
            // Add result of _descendants(child) to list
            descendantsList += _descendants(child)
        }
        
        // Return built list of descendants
        return descendantsList
    }
}

extension SKNode {
    
    private var _gestureRecognizers = [BBUIGestureRecognizer]()
    var gestureRecognizers: [BBUIGestureRecognizer] {
        get {
            return _gestureRecognizers
        }
        set(recognizers) {
            for recognizer in _gestureRecognizers {
                removeGestureRecognizer(recognizer)
            }
            
            for recognizer in recognizers {
                addGestureRecognizer(recognizer)
            }
        }
    }
//
//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        super.touchesBegan(touches, withEvent: event)
//        
//        for recognizer in gestureRecognizers {
//            recognizer.touchesBegan(touches, withEvent: event)
//        }
//    }
//    
//    func addGestureRecognizer(gestureRecognizer: BBUIGestureRecognizer) {
//        if find(gestureRecognizers, gestureRecognizer) == nil {
//            gestureRecognizer.node?.removeGestureRecognizer(gestureRecognizer)
//            gestureRecognizers.append(gestureRecognizer)
//            gestureRecognizer.node = self
//        }
//    }
//    
//    func removeGestureRecognizer(gestureRecognizer: BBUIGestureRecognizer) {
//        if let index = find(gestureRecognizers, gestureRecognizer) {
//            gestureRecognizer.node = nil
//            gestureRecognizers.removeAtIndex(index)
//        }
//    }
}

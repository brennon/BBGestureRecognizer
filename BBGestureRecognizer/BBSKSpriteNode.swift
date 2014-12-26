//
//  BBSKSpriteNode.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/26/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

class BBSKSpriteNode: SKSpriteNode {
    
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        super.touchesBegan(touches, withEvent: event)
        
        for recognizer in gestureRecognizers {
            recognizer.touchesBegan(touches, withEvent: event)
        }
    }
    
    func addGestureRecognizer(gestureRecognizer: BBUIGestureRecognizer) {
        if find(_gestureRecognizers, gestureRecognizer) == nil {
            gestureRecognizer.node?.removeGestureRecognizer(gestureRecognizer)
            gestureRecognizer.node = self
            _gestureRecognizers.append(gestureRecognizer)
        }
    }
    
    func removeGestureRecognizer(gestureRecognizer: BBUIGestureRecognizer) {
        if let index = find(_gestureRecognizers, gestureRecognizer) {
            gestureRecognizer.node = nil
            _gestureRecognizers.removeAtIndex(index)
        }
    }
}

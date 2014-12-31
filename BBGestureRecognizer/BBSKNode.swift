//
//  BBSKNode.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/26/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import ObjectiveC
import SpriteKit

private let gestureRecognizersAssociationKey = malloc(4)

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
    
    var gestureRecognizers: [BBUIGestureRecognizer] {
        get {
            var associatedObject: AnyObject? = objc_getAssociatedObject(self, gestureRecognizersAssociationKey)
            if associatedObject == nil {
                var recognizers = [BBUIGestureRecognizer]()
                objc_setAssociatedObject(self, gestureRecognizersAssociationKey, recognizers, UInt(OBJC_ASSOCIATION_COPY_NONATOMIC))
                associatedObject = objc_getAssociatedObject(self, gestureRecognizersAssociationKey)
            }
            return associatedObject as [BBUIGestureRecognizer]
        }
        set {
            objc_setAssociatedObject(self, gestureRecognizersAssociationKey, newValue, UInt(OBJC_ASSOCIATION_COPY_NONATOMIC))
        }
    }

    // The standard UIResponder methods on this node should pass touches on to 
    // the node's gesture recognizers based on the kind of touch
    public override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        for recognizer in gestureRecognizers {
            recognizer.beginTrackingTouches(touches.allObjects as [UITouch])
            recognizer.continueTrackingTouchesWithEvent(event)
        }
        
        processGestureRecognizers()
    }
    
    public override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        for recognizer in gestureRecognizers {
            recognizer.continueTrackingTouchesWithEvent(event)
        }
        
        processGestureRecognizers()
    }
    
    public override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        super.touchesBegan(touches, withEvent: event)
        
        for recognizer in gestureRecognizers {
            recognizer.continueTrackingTouchesWithEvent(event)
            recognizer.endTrackingTouches(touches.allObjects as [UITouch])
        }
        
        processGestureRecognizers()
    }
    
    public override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        for recognizer in gestureRecognizers {
            recognizer.continueTrackingTouchesWithEvent(event)
            recognizer.endTrackingTouches(touches.allObjects as [UITouch])
        }
        
        processGestureRecognizers()
    }
    
    // Go through gesture recognizers and allow them to process touches
    func processGestureRecognizers() {
        for recognizer in gestureRecognizers {
            recognizer.advanceState()
        }
    }
    
    func addGestureRecognizer(gestureRecognizer: BBUIGestureRecognizer) {
        if find(gestureRecognizers, gestureRecognizer) == nil {
            gestureRecognizer.node?.removeGestureRecognizer(gestureRecognizer)
            gestureRecognizers.append(gestureRecognizer)
            gestureRecognizer.node = self
        }
    }
    
    func removeGestureRecognizer(gestureRecognizer: BBUIGestureRecognizer) {
        if let index = find(gestureRecognizers, gestureRecognizer) {
            gestureRecognizer.node = nil
            gestureRecognizers.removeAtIndex(index)
        }
    }
}

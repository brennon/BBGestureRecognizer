//
//  BBUIGestureRecognizer.swift
//  BBUIGestureRecognizer
//
//  Created by Brennon Bortz on 12/23/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import UIKit
import SpriteKit

protocol BBUIGestureRecognizerTargetAction {
    func performAction(gestureRecognizer: BBUIGestureRecognizer?)
}

struct BBUIGestureRecognizerTargetActionWrapper<T: AnyObject> : BBUIGestureRecognizerTargetAction {
    weak var target: T?
    let action: (T) -> (BBUIGestureRecognizer?) -> ()
    
    func performAction(gestureRecognizer: BBUIGestureRecognizer?) -> () {
        if let t = target {
            action(t)(gestureRecognizer)
        }
    }
}

enum BBUIGestureRecognizerState: Int {
    case BBUIGestureRecognizerStatePossible
    case BBUIGestureRecognizerStateBegan
    case BBUIGestureRecognizerStateChanged
    case BBUIGestureRecognizerStateEnded
    case BBUIGestureRecognizerStateCancelled
    case BBUIGestureRecognizerStateFailed
    case BBUIGestureRecognizerStateRecognized
}

class BBUIGestureRecognizer: Equatable {
    private(set) var state: BBUIGestureRecognizerState = .BBUIGestureRecognizerStatePossible
//    var cancelsTouchesInView = true
//    var delaysTouchesBegan = false
//    var delaysTouchesEnded = true
    var enabled = true
    
    private var _node: SKNode? = nil
    internal(set) var node: SKNode? {
        get {
            return _node
        }
        set(newNode) {
            if newNode != _node {
                reset()
                _node = newNode
            }
        }
    }

    var numberOfTouches: Int {
        return trackingTouches.count
    }
    
    private var registeredAction: BBUIGestureRecognizerTargetAction?
    private var trackingTouches = [UITouch]()
    
    init<T: AnyObject>(target: T, action: (T) -> (BBUIGestureRecognizer?) -> ()) {
        addTarget(target, action: action)
    }
    
    func addTarget<T: AnyObject>(target: T, action: (T) -> (BBUIGestureRecognizer?) -> ()) {
        let targetAction = BBUIGestureRecognizerTargetActionWrapper(target: target, action: action)
        registeredAction = targetAction
    }
    
    func removeTarget() {
        registeredAction = nil
    }
    
    func reset() {
        state = .BBUIGestureRecognizerStatePossible
    }
    
    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        // Begin tracking touches
        beginTrackingTouches(touches.allObjects as [UITouch])
    }
    
    func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    }
    
    func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        
        // End tracking touches
        endTrackingTouches(touches.allObjects as [UITouch])
    }
    
    func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        // End tracking touches
        endTrackingTouches(touches.allObjects as [UITouch])
    }
    
    func locationInNode(node: SKNode!) -> CGPoint? {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var n: CGFloat = 0
        
        for touch in trackingTouches {
            let point = touch.locationInNode(node)
            x += point.x
            y += point.y
            n++
        }
        
        if n > 0 {
            return CGPointMake(x / n, y / n)
        } else {
            return nil
        }
    }
    
    func locationOfTouch(touchIndex index: Int, inNode node: SKNode!) -> CGPoint {
        return trackingTouches[index].locationInNode(node)
    }
    
    private func beginTrackingTouch(touch: UITouch) {
        if enabled {
            trackingTouches.append(touch)
        }
    }
    
    private func beginTrackingTouches(touches: [UITouch]) {
        for touch in touches {
            beginTrackingTouch(touch)
        }
    }
    
    private func endTrackingTouch(touch: UITouch) {
        if enabled {
            if let index = find(trackingTouches, touch) {
                trackingTouches.removeAtIndex(index)
            }
        }
    }
    
    private func endTrackingTouches(touches: [UITouch]) {
        for touch in touches {
            endTrackingTouch(touch)
        }
    }
}

func ==(lhs: BBUIGestureRecognizer, rhs: BBUIGestureRecognizer) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

// http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/
// https://github.com/BigZaphod/Chameleon/blob/master/UIKit/Classes/UIGestureRecognizer.m

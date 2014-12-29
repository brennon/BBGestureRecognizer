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

protocol BBUIGestureRecognizerDelegate {
    
    // called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
    func gestureRecognizerShouldBegin(gestureRecognizer: BBUIGestureRecognizer) -> Bool
    
    // called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
    // return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
    //
    // note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
    func gestureRecognizer(gestureRecognizer: BBUIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    
    // called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
    func gestureRecognizer(gestureRecognizer: BBUIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
}

class BBUIGestureRecognizer: Equatable, Printable {
    private(set) var state: BBUIGestureRecognizerState = .BBUIGestureRecognizerStatePossible
//    var cancelsTouchesInView = true
//    var delaysTouchesBegan = false
//    var delaysTouchesEnded = true
    var enabled = true
    
    var delegate: BBUIGestureRecognizerDelegate? = nil
    
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
        println("touches began in recognizer")
    }
    
    func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        println("touches moved in recognizer")
    }
    
    func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        println("touches cancelled in recognizer")
    }
    
    func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        println("touches ended in recognizer")
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
        
        // If this recognizer is enabled
        if enabled {
            
            // If there is no delgate or the delegate says this recognizer 
            // should receive this touch, add this touch to trackingTouches
            var shouldReceiveTouch = true
            if let actualDelegate = delegate {
                shouldReceiveTouch = actualDelegate.gestureRecognizer(
                    self,
                    shouldReceiveTouch: touch
                )
            }
            
            if shouldReceiveTouch {
                trackingTouches.append(touch)
            }
        }
    }
    
    internal func beginTrackingTouches(touches: [UITouch]) {
        for touch in touches {
            beginTrackingTouch(touch)
        }
    }
    
    internal func continueTrackingTouchesWithEvent(event: UIEvent) {
        var began = NSMutableSet()
        var moved = NSMutableSet()
        var ended = NSMutableSet()
        var cancelled = NSMutableSet()
        
        var multitouchSequenceIsEnded = true
        
        for touch in trackingTouches {
            switch touch.phase {
            case .Began:
                multitouchSequenceIsEnded = false
                began.addObject(touch)
            case .Moved:
                multitouchSequenceIsEnded = false
                moved.addObject(touch)
            case .Stationary:
                multitouchSequenceIsEnded = false
            case .Ended:
                ended.addObject(touch)
            case .Cancelled:
                cancelled.addObject(touch)
            }
        }
        
        switch state {
        case .BBUIGestureRecognizerStatePossible,
             .BBUIGestureRecognizerStateBegan,
             .BBUIGestureRecognizerStateChanged:
            
            if began.count > 0 {
                touchesBegan(began, withEvent: event)
            }
            
            if moved.count > 0 {
                touchesMoved(moved, withEvent: event)
            }
            
            if ended.count > 0 {
                touchesEnded(ended, withEvent: event)
            }
            
            if cancelled.count > 0 {
                touchesCancelled(cancelled, withEvent: event)
            }
        default:
            break
        }
        

        // if all the touches are ended or cancelled, then the multitouch sequence must be over - so we can reset
        // our state back to normal and clear all the tracked touches, etc. to get ready for a new touch sequence
        // in the future.
        // this also applies to the special discrete gesture events because those events are only sent once!
        if multitouchSequenceIsEnded {
            
            // see note above in -setState: about the delay here!
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.reset()
            }
        }
    }
    
    private func endTrackingTouch(touch: UITouch) {
        if enabled {
            if let index = find(trackingTouches, touch) {
                trackingTouches.removeAtIndex(index)
            }
        }
    }
    
    internal func endTrackingTouches(touches: [UITouch]) {
        for touch in touches {
            endTrackingTouch(touch)
        }
    }
    
    var description: String {
        var stateString: String
        
        switch (state) {
        case .BBUIGestureRecognizerStatePossible:
            stateString = "Possible"
        case .BBUIGestureRecognizerStateBegan:
            stateString = "Began"
        case .BBUIGestureRecognizerStateChanged:
            stateString = "Changed"
        case .BBUIGestureRecognizerStateEnded:
            stateString = "Ended"
        case .BBUIGestureRecognizerStateCancelled:
            stateString = "Cancelled"
        case .BBUIGestureRecognizerStateFailed:
            stateString = "Failed"
        case .BBUIGestureRecognizerStateRecognized:
            stateString = "Recognized"
        }
        
        let thisType = ObjectIdentifier(self)
        return "<BBUIGestureRecognizer; state = \(stateString); node = \(node)>"
    }
}

func ==(lhs: BBUIGestureRecognizer, rhs: BBUIGestureRecognizer) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

// http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/
// https://github.com/BigZaphod/Chameleon/blob/master/UIKit/Classes/UIGestureRecognizer.m

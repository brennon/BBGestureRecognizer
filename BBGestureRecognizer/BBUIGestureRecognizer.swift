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

enum BBUIGestureRecognizerState: Int, Printable {
    case Possible
    case Began
    case Changed
    case Ended
    case Cancelled
    case Failed
    case Recognized
    
    var description: String {
        switch(self) {
        case Possible:
            return "Possible"
        case Began:
            return "Began"
        case Changed:
            return "Changed"
        case Ended:
            return "Ended"
        case Cancelled:
            return "Cancelled"
        case Failed:
            return "Failed"
        case Recognized:
            return "Recognized"
        }
    }
}

struct BBUIGestureRecognizerStateTransition {
    let fromState: BBUIGestureRecognizerState
    let toState: BBUIGestureRecognizerState
    let shouldNotify: Bool
}

/**
    `BBUIGestureRecognizer` is a base class for concrete gesture-recognizer 
    classes that can be attached to `BBSKNode` instances. A gesture-recognizer 
    object--or, simply, a gesture recognizer--decouples the logic for
    recognizing a gesture and acting on that recognition. When one of these 
    objects recognizes a common gesture or, in some cases, a change in the 
    gesture, it sends an action message to each designated target object.
    <br /><br />
    The `BBUIGestureRecognizer` class defines a set of common behaviors that can 
    be configured for subclassed gesture recognizers. It can also communicate 
    with its delegate (an object that conforms to the 
    `BBUIGestureRecognizerDelegate` protocol), thereby enabling finer-grained 
    customization of some behaviors.
    <br /><br />
    A gesture recognizer operates on touches hit-tested to a specific `BBSKNode` 
    and all of that node's descendant nodes. It thus must be associated with 
    that view. To make that association you must call the `BBSKNode` method
    `addGestureRecognizer:`.
    <br /><br />
    A gesture recognizer has a method associated with it. Recognition of a 
    gesture results in calling this method. The action method must conform to 
    the signature: `(BBUIGestureRecognizer?) -> ()`
    <br /><br />
    Beyond this, a `BBUIGestureRecognizer` operates much like a 
    `UIGestureRecognizer`. See the documentation for `UIGestureRecognizer` for 
    further information.
*/
class BBUIGestureRecognizer: Equatable, Printable {
    
    /**
        Only certain transitions from one `BBUIGestureRecognizerState` to
        another are allowed. `allowedStateTransitions` is an 
        `[BBUIGestureRecognizerStateTransition]` that includes those transitions 
        that are allowed.
    */
    private let allowedStateTransitions: [BBUIGestureRecognizerStateTransition] = [
        BBUIGestureRecognizerStateTransition(
            fromState: .Possible,
            toState: .Recognized,
            shouldNotify: true
        ),
        BBUIGestureRecognizerStateTransition(
            fromState: .Possible,
            toState: .Failed,
            shouldNotify: false
        ),
        BBUIGestureRecognizerStateTransition(
            fromState: .Possible,
            toState: .Began,
            shouldNotify: true
        ),
        BBUIGestureRecognizerStateTransition(
            fromState: .Began,
            toState: .Changed,
            shouldNotify: true
        ),
        BBUIGestureRecognizerStateTransition(
            fromState: .Began,
            toState: .Cancelled,
            shouldNotify: true
        ),
        BBUIGestureRecognizerStateTransition(
            fromState: .Began,
            toState: .Ended,
            shouldNotify: true
        ),
        BBUIGestureRecognizerStateTransition(
            fromState: .Changed,
            toState: .Changed,
            shouldNotify: true
        ),
        BBUIGestureRecognizerStateTransition(
            fromState: .Changed,
            toState: .Cancelled,
            shouldNotify: true
        ),
        BBUIGestureRecognizerStateTransition(
            fromState: .Changed,
            toState: .Ended,
            shouldNotify: true
        )
    ]
    
    /**
        Determines if a transition from one `BBUIGestureRecognizerState` to 
        another is allowed (is contained in `allowedStateTransitions`).
    
        :param: fromState The beginning state of the transition.
        :param: toState The ending state of the transition.
    
        :returns: Returns the allowed `BBUIGestureRecognizerStateTransition` if 
            it is present in `allowedStateTransitions`, otherwise it returns
            `nil`.
    */
    private func findAllowedTransition(fromState: BBUIGestureRecognizerState, toState: BBUIGestureRecognizerState) -> BBUIGestureRecognizerStateTransition? {
        for transition in allowedStateTransitions {
            if transition.fromState == fromState && transition.toState == toState {
                return transition
            }
        }
        
        return nil
    }
    
    /// Private storage for the `state` property.
    private var _state: BBUIGestureRecognizerState = .Possible
    
    /**
        The current `BBUIGestureRecognizerState` of the gesture recognizer. When 
        `state` transitions from `.Possible` to `.Began` or `.Recognized` and 
        the `delegate` (if set) prevents the gesture recognizer from beginning, 
        `state` is automatically set to `.Failed`. Otherwise, `state` is only 
        updated if the transition is allowed (see `allowedStateTransitions`). 
        Lastly, if the allowed transition (if found) has `shouldNotify` set to 
        `true`, the gesture recognizer's associated action method is called.
    */
    internal(set) var state: BBUIGestureRecognizerState {
        get {
            return _state
        }
        set(newState) {
            
            var varNewState = newState
            
            // If there is a delegate and it says that this recognizer should
            // not begin, set the new state to .Failed
            var shouldBegin = true
            if let actualDelegate = delegate {
                if _state == .Possible {
                    if newState == .Began || newState == .Recognized {
                        shouldBegin = actualDelegate.gestureRecognizerShouldBegin(self)
                    }
                }
            }
            
            if !shouldBegin {
                varNewState = .Failed
            }
            
            if let allowedTransition = findAllowedTransition(_state, toState: varNewState) {
                _state = varNewState
                
                // docs mention that the action messages are sent on the next run loop, so we'll do that here.
                // note that this means that reset can't happen until the next run loop, either otherwise
                // the state property is going to be wrong when the action handler looks at it, so as a result
                // I'm also delaying the reset call (if necessary) below in -continueTrackingWithEvent:
                if allowedTransition.shouldNotify {
                    registeredAction?.performAction(self)
                }
            } else {
                println("Invalid state transition from \(_state) to \(varNewState)")
            }
        }
    }
    
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
    
    /**
        Initializes an allocated gesture-recognizer object with a target and an 
        action selector.
    
        :param: target An object on which a method will be called when this 
            gesture recognizer recognizes a gesture. `nil` is not a valid value.
        :param: action A method implemented by the target to handle the gesture 
            recognized by the receiver. The method must conform to the signature 
            described in the class overview. `nil` is not a valid value.
    */
    init<T: AnyObject>(target: T, action: (T) -> (BBUIGestureRecognizer?) -> ()) {
        addTarget(target, action: action)
    }
    
    func addTarget<T: AnyObject>(target: T, action: (T) -> (BBUIGestureRecognizer?) -> ()) {
        let targetAction = BBUIGestureRecognizerTargetActionWrapper(target: target, action: action)
        registeredAction = targetAction
        let a = UIGestureRecognizer()
    }
    
    func removeTarget() {
        registeredAction = nil
    }
    
    func reset() {
        state = .Possible
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
        case .Possible,
             .Began,
             .Changed:
            
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
        case .Possible:
            stateString = "Possible"
        case .Began:
            stateString = "Began"
        case .Changed:
            stateString = "Changed"
        case .Ended:
            stateString = "Ended"
        case .Cancelled:
            stateString = "Cancelled"
        case .Failed:
            stateString = "Failed"
        case .Recognized:
            stateString = "Recognized"
        }
        
        let thisType = ObjectIdentifier(self)
        return "<BBUIGestureRecognizer; state = \(stateString); node = \(node)>"
    }
    
//- (void)requireGestureRecognizerToFail:(UIGestureRecognizer *)otherGestureRecognizer
//{
//}
//- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
//{
//return YES;
//}
//
//- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
//{
//return YES;
//}
//
//- (void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent*)event
//{
//}
}

func ==(lhs: BBUIGestureRecognizer, rhs: BBUIGestureRecognizer) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

// http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/
// https://github.com/BigZaphod/Chameleon/blob/master/UIKit/Classes/UIGestureRecognizer.m

//
//  BBTapTapDragGestureRecognizer.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 1/9/15.
//
//

import UIKit
import SpriteKit

/**
`BBTapGestureRecognizer` is a subclass of `BBGestureRecognizer` that looks for single or multiple taps. For the gesture to be
recognized, the specified number of fingers must tap the view a specified number of times.
<br /><br />
Although taps are discrete gestures, they are discrete for each state of the gesture recognizer; thus the associated action
message is sent when the gesture begins and is sent for each intermediate state until (and including) the ending state of the
gesture. Code that handles tap gestures should therefore test for the state of the gesture.
<br /><br />
Action methods handling this gesture may get the location of the gesture as a whole by calling the `BBGestureRecognizer`
method `locationInNode(_:)`; if there are multiple taps, this location is the first tap; if there are multiple touches, this
location is the centroid of all fingers tapping the view. Clients may get the location of particular touches in the tap by
calling `locationOfTouch(_:inNode:)`; if multiple taps are allowed, this location is that of the first tap.
*/
class BBTapTapDragGestureRecognizer: BBGestureRecognizer {
    
    // MARK: Initializing a Tap Gesture Recognizer
    
    /**
    Initializes an allocated `BBTapGestureRecognizer` object with a target object and method to be called on gesture
    recognition.
    
    :param: target An object on which a method will be called when this gesture recognizer recognizes a gesture. `nil` is not
    a valid value.
    :param: action A method implemented by the target to handle the gesture recognized by the receiver. The method must
    conform to the signature described in the `BBGestureRecognizer` class overview. `nil` is not a valid value.
    */
    override init<T : AnyObject>(target: T, action: (T) -> (BBGestureRecognizer?) -> ()) {
        super.init(target: target, action: action)
    }
    
    // MARK: Configuring the Gesture
    
    /**
    The maximum time that can elapse between two successive taps. The gesture recognizer will wait this long after it
    receives its last tap before transitioning to the `.Recognized` state. This is to allow for failure dependency
    relationships to be established between tap recognizers. For instance, a single-tap recognizer must wait to transition
    to `.Recognized` if there may be a double-tap recognizer that is expecting it to fail.
    */
    var maximumIntervalBetweenSuccessiveTaps: NSTimeInterval = 0.25
    private var secondTapHasReleased = false
    private var secondTapStartTime: NSDate!
    
    // MARK: Tracking the Location and Velocity of the Gesture
    
    // FIXME: Update documentation--not doing any coordinate conversion as it is unnecessary for a relative measure
    
    /**
    The translation of the pan gesture in the coordinate system of the specified view. The x and y values report the total
    translation over time. They are not delta values from the last time that the translation was reported. Apply the
    translation value to the state of the node when the gesture is first recognized--do not concatenate the value each time
    the handler is called.
    
    :param: node The node in whose coordinate system the translation of the pan gesture should be computed. If you want to
    adjust a node's location to keep it under the user's finger, request the translation in that node's parent's
    coordinate system.
    
    :returns: A point identifying the new location of a node in the coordinate system of its parent node.
    */
    func translationInNode(node: SKNode) -> CGPoint {
        assertThatNodeAndSceneAreValid()
        
        if node == self.node?.scene? {
            return _translation
        } else {
            return self.node!.scene!.convertPoint(_translation, toNode: node)
        }
    }
    
    /**
    Sets the translation value in the coordinate system of the specified node. Changing the translation value resets the
    velocity of the pan.
    
    :param: translation A point that identifies the new translation value.
    :param: node A node in whose coordinate system the translation is to occur.
    */
    func setTranslation(translation: CGPoint, inNode node: SKNode!) {
        _velocity = CGPointZero
        _translation = self.node!.scene!.convertPoint(translation, fromNode: node)
    }
    
    /**
    The velocity of the pan gesture in the coordinate system of the specified node.
    
    :param: node The node in whose coordinate system the velocity of the pan gesture is computed
    
    :returns: The velocity of the pan gesture, which is expressed in points per second. The velocity is broken into
    horizontal and vertical components.
    */
    func velocityInNode(node: SKNode) -> CGPoint {
        assertThatNodeAndSceneAreValid()
        
        if node == self.node?.scene? {
            return _velocity
        } else {
            return self.node!.scene!.convertPoint(_velocity, toNode: node)
        }
    }
    
    // MARK: Touch Handling
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        if state == .Possible {
        
            // Has the touch tapped once already and is now down again?
            let firstTouch = touches.allObjects.first as UITouch
            
            if firstTouch.tapCount == 2 {
                
                secondTapHasReleased = false
                secondTapStartTime = NSDate()
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(maximumIntervalBetweenSuccessiveTaps * NSTimeInterval(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    if !self.secondTapHasReleased {
                        self.state = .Began
                        
                        let newLocation = firstTouch.locationInNode(self.node!.scene!)
                        self._lastLocation = newLocation
                        self._lastMovementTime = event.timestamp
                    } else {
                        self.state = .Failed
                    }
                    self.advanceState()
                }
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        if state == .Began {
            state = .Changed
        }
        
        if state == .Began || state == .Changed {
            
            let firstTouch = touches.allObjects.first as UITouch
            
            let newLocation = firstTouch.locationInNode(node!.scene!)
            
            let translation = CGPointMake(newLocation.x - _lastLocation.x, newLocation.y - _lastLocation.y)
            
            _lastLocation = newLocation
            
            if translate(translation, withEvent: event) {
                state = .Changed
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        // Did the first touch tap and release twice?
        let firstTouch = touches.allObjects.first as UITouch
        
        if firstTouch.tapCount == 2 {
            
            // Has the maximum interval between successive taps not yet passed?
            let elapsedTime = NSDate().timeIntervalSinceDate(secondTapStartTime)
            if elapsedTime < maximumIntervalBetweenSuccessiveTaps {
                secondTapHasReleased = true
            }
        } else if state == .Changed {
            
            let newLocation = firstTouch.locationInNode(node!.scene!)
            
            let translation = CGPointMake(newLocation.x - _lastLocation.x, newLocation.y - _lastLocation.y)
            
            translate(translation, withEvent: event)
            
            state = .Ended
        }
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        
        switch state {
        case .Began, .Changed:
            state = .Cancelled
        default:
            break
        }
    }
    
    /// MARK: Private Properties/Methods
    
    private var _firstLocation = CGPointZero
    
    private var _lastLocation = CGPointZero
    
    private var _translation = CGPointZero
    
    private var _velocity = CGPointZero
    
    private var _lastMovementTime: NSTimeInterval!
    
    private var _pastVelocities = [CGPoint]()
    private var _numberOfPastVelocitiesToTrack = 3
    
    private func translate(translation: CGPoint, withEvent event: UIEvent) -> Bool {
        let timeDelta = event.timestamp - _lastMovementTime
        
        if !CGPointEqualToPoint(translation, CGPointZero) && timeDelta > 0 {
            _translation.x += translation.x
            _translation.y += translation.y
            
            let newVelocity = CGPointMake(translation.x / CGFloat(timeDelta), translation.y / CGFloat(timeDelta))
            
            if _pastVelocities.count > 3 {
                _pastVelocities.removeAtIndex(0)
            }
            
            _pastVelocities.append(newVelocity)
            
            let averageVelocity = _pastVelocities.reduce(CGPointZero) {
                var initial = $0
                var next = $1
                return CGPointMake(initial.x + next.x / CGFloat(self._pastVelocities.count), initial.y + next.y / CGFloat(self._pastVelocities.count))
            }
            
            _velocity = averageVelocity
            _lastMovementTime = event.timestamp
            return true
        } else {
            return false
        }
    }
    
    override func reset() {
        super.reset()
        
        _firstLocation = CGPointZero
        _lastLocation = CGPointZero
        _translation = CGPointZero
        _velocity = CGPointZero
        _pastVelocities = [CGPoint]()
        
        secondTapHasReleased = false
        secondTapStartTime = nil
    }
    
    private func assertThatNodeAndSceneAreValid() {
        assert(node != nil, "Gesture recognizer processing touches when it's node is nil")
        assert(node!.scene != nil, "Gesture recognizer processing touches when it's node's scene is nil")
    }
}


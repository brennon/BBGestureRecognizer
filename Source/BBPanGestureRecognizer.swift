//
//  BBPanGestureRecognizer.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 1/4/15.
//
//

import UIKit
import SpriteKit

/**
    `BBPanGestureRecognizer` is a subclass of `BBGestureRecognizer` that looks for panning (dragging) gestures. The user must be 
    pressing one or more fingers on a view while they pan it. Clients implementing the action method for this gesture recognizer 
    can ask it for the current translation and velocity of the gesture.
    <br /><br />
    A panning gesture is continuous. It begins (`BBGestureRecognizerState.Began`) when the minimum number of fingers allowed
    (`minimumNumberOfTouches`) has moved enough to be considered a pan. It changes (`BBGestureRecognizerState.Changed`) when a 
    finger moves while at least the minimum number of fingers are pressed down. It ends (`BBGestureRecognizerState.Ended`) when 
    all fingers are lifted.
    <br /><br />
    Clients of this class can, in their action methods, query the `BBPanGestureRecognizer` object for the current translation of 
    the gesture (`translationInNode(_:)`) and the velocity of the translation (`velocityInNode(_:)`). They can specify the node 
    whose coordinate system should be used for the translation and velocity values. Clients may also reset the translation to a 
    desired value.
*/
class BBPanGestureRecognizer: BBGestureRecognizer {
    
    // MARK: Initializing a Pan Gesture Recognizer
    
    /**
        Initializes an allocated `BBPanGestureRecognizer` object with a target object and method to be called on gesture 
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
    
    // FIXME: Observe maximum and minimum number of touches
    
    /**
        The maximum number of fingers that can be touching the view for this gesture to be recognized. The default value is 
        `Int.max`.
    */
    var maximumNumberOfTouches: Int = Int.max
    
    /**
        The number of fingers required to tap for the gesture to be recognized. The default value is `1`.
    */
    var minimumNumberOfTouches: Int = 1
    
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
        assertThatNodeAndSceneAreValid()
        
        super.touchesBegan(touches, withEvent: event)
        
        let firstTouch = touches.allObjects.first as UITouch
        
        let newLocation = firstTouch.locationInNode(node!.scene!)
        
        _firstLocation = newLocation
        _lastLocation = newLocation
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        assertThatNodeAndSceneAreValid()
        
        super.touchesMoved(touches, withEvent: event)
        
        let firstTouch = touches.allObjects.first as UITouch
        
        let newLocation = firstTouch.locationInNode(node!.scene!)
        
        if state == .Possible {
            
            // Get distance from first location to this one
            let deltaX = newLocation.x - _firstLocation.x
            let deltaY = newLocation.y - _firstLocation.y
            let distanceSquared = pow(deltaX, 2) + pow(deltaY, 2)
            
            if distanceSquared >= 25 {
                    _lastLocation = _firstLocation
                    _lastMovementTime = event.timestamp
                    state = .Began
            }
        } else if state == .Began || state == .Changed {
            let translation = CGPointMake(newLocation.x - _lastLocation.x, newLocation.y - _lastLocation.y)
            
            _lastLocation = newLocation
            
            if translate(translation, withEvent: event) {
                state = .Changed
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        assertThatNodeAndSceneAreValid()
        
        super.touchesEnded(touches, withEvent: event)
        
        let firstTouch = touches.allObjects.first as UITouch
        
        let newLocation = firstTouch.locationInNode(node!.scene!)
        
        let translation = CGPointMake(newLocation.x - _lastLocation.x, newLocation.y - _lastLocation.y)
        
        if state == .Began || state == .Changed {
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
    
    // MARK: Private Properties/Methods
    
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
    }
    
    private func assertThatNodeAndSceneAreValid() {
        assert(node != nil, "Gesture recognizer processing touches when it's node is nil")
        assert(node!.scene != nil, "Gesture recognizer processing touches when it's node's scene is nil")
    }
}


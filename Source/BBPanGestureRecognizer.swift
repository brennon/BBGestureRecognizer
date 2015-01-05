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
    func translationInNode() -> CGPoint {
        return _translation
    }
    
    /**
        Sets the translation value in the coordinate system of the specified node. Changing the translation value resets the 
        velocity of the pan.
    
        :param: translation A point that identifies the new translation value.
        :param: node A node in whose coordinate system the translation is to occur.
    */
    func setTranslation(translation: CGPoint) {
        _velocity = CGPointZero
        _translation = translation
    }
    
    /**
        The velocity of the pan gesture in the coordinate system of the specified node.
    
        :param: node The node in whose coordinate system the velocity of the pan gesture is computed
    
        :returns: The velocity of the pan gesture, which is expressed in points per second. The velocity is broken into 
            horizontal and vertical components.
    */
    func velocityInNode() -> CGPoint {
        return _velocity
    }
    
    // MARK: Touch Handling
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        if state == .Possible {
            _lastLocation = locationInNode(node)!
            _lastMovementTime = event.timestamp
            state = .Began
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        let firstTouch = touches.allObjects.first as UITouch
        let newLocation = locationInNode(node)!
        
        let translation = CGPointMake(newLocation.x - _lastLocation.x, newLocation.y - _lastLocation.y)
        
        _lastLocation = newLocation
        
        if translate(translation, withEvent: event) {
            state = .Changed
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        let newLocation = locationInNode(node)!
        
        if state == .Began || state == .Changed {
            translate(newLocation, withEvent: event)
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
    
    private var _lastLocation = CGPointZero
    
    private var _translation = CGPointZero
    
    private var _velocity = CGPointZero
    
    private var _lastMovementTime: NSTimeInterval!
    
    private func translate(translation: CGPoint, withEvent event: UIEvent) -> Bool {
//        println("translate called with \(translation)")
        let timeDelta = event.timestamp - _lastMovementTime
        
        if !CGPointEqualToPoint(translation, CGPointZero) && timeDelta > 0 {
            _translation.x += translation.x
            _translation.y += translation.y
            _velocity.x = translation.x / CGFloat(timeDelta)
            _velocity.y = translation.y / CGFloat(timeDelta)
            _lastMovementTime = event.timestamp
            return true
        } else {
            return false
        }
    }
    
    override func reset() {
        super.reset()
        
        _lastLocation = CGPointZero
        _translation = CGPointZero
        _velocity = CGPointZero
    }
}


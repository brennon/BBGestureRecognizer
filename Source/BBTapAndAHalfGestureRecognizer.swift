//
//  BBTapAndAHalfGestureRecognizer.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 1/8/15.
//
//

import UIKit

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
class BBTapAndAHalfGestureRecognizer: BBGestureRecognizer {
    
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
    
    // MARK: Touch Handling
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        // Has the touch tapped once already and is now down again?
        let firstTouch = touches.allObjects.first as UITouch
        
        if firstTouch.tapCount == 2 {
            
            secondTapHasReleased = false
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(maximumIntervalBetweenSuccessiveTaps * NSTimeInterval(NSEC_PER_SEC)))
            
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                if !self.secondTapHasReleased {
                    self.state = .Recognized
                } else {
                    self.state = .Failed
                }
                self.advanceState()
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        // Did the first touch tap and release twice?
        let firstTouch = touches.allObjects.first as UITouch
        
        if firstTouch.tapCount == 2 {
            secondTapHasReleased = true
        }
    }

    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        state = .Cancelled
    }
    
    override func reset() {
        super.reset()
    }
}


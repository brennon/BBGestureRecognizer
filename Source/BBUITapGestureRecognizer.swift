//
//  BBUITapGestureRecognizer.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/30/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import Foundation
import UIKit

/**
    `BBUITapGestureRecognizer` is a subclass of `BBUIGestureRecognizer` that 
    looks for single or multiple taps. For the gesture to be recognized, the 
    specified number of fingers must tap the view a specified number of times.
    <br /><br />
    Although taps are discrete gestures, they are discrete for each state of 
    the gesture recognizer; thus the associated action message is sent when the 
    gesture begins and is sent for each intermediate state until (and 
    including) the ending state of the gesture. Code that handles tap gestures 
    should therefore test for the state of the gesture.
    <br /><br />
    Action methods handling this gesture may get the location of the gesture as 
    a whole by calling the `BBUIGestureRecognizer` method `locationInNode(_:)`; 
    if there are multiple taps, this location is the first tap; if there are 
    multiple touches, this location is the centroid of all fingers tapping the 
    view. Clients may get the location of particular touches in the tap by 
    calling `locationOfTouch(_:inNode:)`; if multiple taps are allowed, this 
    location is that of the first tap.
*/
class BBUITapGestureRecognizer: BBUIGestureRecognizer {
    
    // MARK: Initializing a Tap Gesture Recognizer
    
    /**
        Initializes an allocated `BBUITapGestureRecognizer` object with a 
        target object and method to be called on gesture recognition.
    
        :param: target An object on which a method will be called when this
            gesture recognizer recognizes a gesture. `nil` is not a valid value.
        :param: action A method implemented by the target to handle the gesture
            recognized by the receiver. The method must conform to the signature
            described in the `BBUIGestureRecognizer` class overview. `nil` is 
            not a valid value.
    */
    override init<T : AnyObject>(target: T, action: (T) -> (BBUIGestureRecognizer?) -> ()) {
        super.init(target: target, action: action)
    }
    
    // MARK: Configuring the Gesture
    
    /**
        The number of taps for the gesture to be recognized. The default value 
        is 1.
    */
    var numberOfTapsRequired: Int = 1
    
    /**
        The number of fingers required to tap for the gesture to be recognized. 
        The default value is 1.
    */
    var numberOfTouchesRequired: Int = 1
    
    /**
        The maximum time that can elapse between two successive taps. The gesture recognizer will wait this long after it 
        receives its last tap before transitioning to the `.Recognized` state. This is to allow for failure dependency 
        relationships to be established between tap recognizers. For instance, a single-tap recognizer must wait to transition 
        to `.Recognized` if there may be a double-tap recognizer that is expecting it to fail.
    */
    var maximumIntervalBetweenSuccessiveTaps: NSTimeInterval = 0.25
    
    // MARK: Touch Handling
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        // Are there the correct number of touches?
        if touches.count == numberOfTouchesRequired {
            
            // Are we now seeing too many taps?
            if tooManyTapsForSomeTouch(touches) {
                updatePendingRecognition(.Failed)
            }
        
        // Otherwise, we have the wrong number of touches
        } else {
            
            // Set state to Failed and ignore all touches in this event
            failRecognizerAndIgnoreTouches(touches, withEvent: event)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        // Are there still the correct number of touches?
        if touches.count == numberOfTouchesRequired {
            
            // If all touches have tapped the correct number of times
            if correctTapCountForAllTouches(touches) {
                schedulePendingRecognition(.Recognized, andDelay: maximumIntervalBetweenSuccessiveTaps)
            }
        
        // Otherwise, we have the wrong number of touches
        } else {
            
            // Set state to Failed and ignore all touches in this event
            failRecognizerAndIgnoreTouches(touches, withEvent: event)
        }
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        state = .Cancelled
    }
    
    // MARK: Private Methods
    
    private func correctTapCountForAllTouches(touches: NSSet) -> Bool {
        // If all touches have tapped the correct number of times
        var correctTapCount = true
        
        for touch in touches.allObjects as [UITouch] {
            if touch.tapCount != numberOfTapsRequired {
                correctTapCount = false
            }
        }
        
        return correctTapCount
    }
    
    private func tooManyTapsForSomeTouch(touches: NSSet) -> Bool {
        for touch in touches.allObjects as [UITouch] {
            if touch.tapCount > numberOfTapsRequired {
                return true
            }
        }
        
        return false
    }
    
    private func failRecognizerAndIgnoreTouches(touches: NSSet, withEvent event: UIEvent) {
        state = .Failed
        for touch in touches.allObjects as [UITouch] {
            ignoreTouch(touch, forEvent: event)
        }
    }
    
    override func reset() {
        super.reset()
        println("resetting in subclass")
//        stateAfterDelay = nil
    }
}

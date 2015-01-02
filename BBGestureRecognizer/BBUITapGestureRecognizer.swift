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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        // If the number of touches matches the required number and we are in 
        // the .Possible state
        if touches.count == numberOfTouchesRequired && state == .Possible {
            
            var newState: BBUIGestureRecognizerState
            
            // Set the state to .Began
            let firstTouch = touches.allObjects.first as UITouch
            if firstTouch.tapCount > numberOfTapsRequired {
                newState = .Failed
            } else {
                newState = .Began
            }
            
            println("changing \(name) from \(state) to .\(newState)")
            state = newState
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        // If we no longer have the correct number of touches, set the state
        // to .Cancelled if necessary, reset, and return immediately
        if touches.count != numberOfTouchesRequired {
            
            // If state is .Began, it needs to become .Cancelled. If state is
            // .Possible, leave it at .Possible and just reset.
            if state == .Began {
                state = .Cancelled
            }
            return
        }
        
        // We know we have the correct number of touches. Now, if we are in the 
        // .Began or .Changed state
        var newState: BBUIGestureRecognizerState = .Ended
        if state == .Began || state == .Changed {
            
            // If the first touch has not yet tapped the correct number of times
            let firstTouch = touches.allObjects.first as UITouch
            if firstTouch.tapCount < numberOfTapsRequired {
                newState = .Changed
            } else if firstTouch.tapCount == numberOfTapsRequired {
                newState = .Ended
            } else if firstTouch.tapCount > numberOfTapsRequired {
                newState = .Failed
            }
        }
        
        println("changing \(name) from \(state) to .\(newState)")
        state = newState
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        
        state = .Cancelled
    }
}

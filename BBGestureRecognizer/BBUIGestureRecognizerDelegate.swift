//
//  BBUIGestureRecognizerDelegate.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/29/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import UIKit

/**
Delegates of a gesture recognizer--that is, an instance of a subclass of
`BBUIGestureRecognizer`--adopt the UIGestureRecognizerDelegate protocol to
fine-tune an app’s gesture-recognition behavior. The delegates receive
messages from a gesture recognizer, and their responses to these messages
enable them to affect the operation of the gesture recognizer or to specify
a relationship between it and another gesture recognizer, such as allowing
simultaneous recognition or setting up a failure requirement.
*/
protocol BBUIGestureRecognizerDelegate {
    
    // MARK: Regulating Gesture Recognition
    
    /**
    Asks the delegate if a gesture recognizer should begin interpreting
    touches. This method is called when a gesture recognizer attempts to
    transition out of the state `.Possible`. Returning `false` causes the
    gesture recognizer to transition to the state `.Failed`.
    
    :param: gestureRecognizer An instance of a subclass of the base class
    `BBUIGestureRecognizer`. This gesture recognizer object is about to
    begin processing touches to determine if its gesture is occurring.
    
    :returns: `true` (the default) to tell the gesture recognizer to proceed
    with interpreting touches, `false` to prevent it from attempting to
    recognize its gesture.
    */
    func gestureRecognizerShouldBegin(gestureRecognizer: BBUIGestureRecognizer) -> Bool
    
    /**
    Ask the delegate if a gesture recognizer should receive an object
    representing a touch. This method is called before
    `touchesBegan(_:withEvent)` is called on the gesture recognizer for a
    new touch.
    
    :param: gestureRecognizer An instance of a subclass of the base class
    `BBUIGestureRecognizer`.
    :param: touch A `UITouch` object from the current multi-touch sequence.
    
    :returns: `true` (the default) to allow the gesture recognizer to
    examine the touch object, `false` to prevent the gesture recognizer
    from seeing this touch object.
    */
    func gestureRecognizer(gestureRecognizer: BBUIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    
    
    // MARK: Controlling Simultaneous Gesture Recognition
    
    /**
    Asks the delegate if two gesture recognizers should be allowed to
    recognize gestures simultaneously. This method is called when
    recognition of a gesture by either `gestureRecognizer` or
    `otherGestureRecognizer` would block the other gesture recognizer from
    recognizing its gesture. Note that returning `true` is guaranteed to
    allow simultaneous recognition; returning `false`, on the other hand, is
    not guaranteed to prevent simultaneous recognition because the other
    gesture recognizer's delegate may return `true`.
    
    :param: gestureRecognizer An instance of a subclass of the base class
    `BBUIGestureRecognizer`. This is the object calling the message on
    the delegate.
    :param: otherGestureRecognizer An instance of a subclass of the base
    class `UIGestureRecognizer`.
    
    :returns: `true` to allow both `gestureRecognizer` and
    `otherGestureRecognizer` to recognize their gestures simultaneously.
    The default implementation returns `false`--no two gestures can be
    recognized simultaneously.
    */
    func gestureRecognizer(gestureRecognizer: BBUIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: BBUIGestureRecognizer) -> Bool
}

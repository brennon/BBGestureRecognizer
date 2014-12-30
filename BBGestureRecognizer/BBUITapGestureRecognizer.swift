//
//  BBUITapGestureRecognizer.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/30/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import Foundation
import UIKit

class BBUITapGestureRecognizer: BBUIGestureRecognizer {
    
    var tapStartTime: NSDate!
    var maximumTapDuration: NSTimeInterval = 1.0
    
    override init<T : AnyObject>(target: T, action: (T) -> (BBUIGestureRecognizer?) -> ()) {
        super.init(target: target, action: action)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        // If we have a single touch and we are in the .Possible state
        if touches.count == 1  && state == .Possible {
            
            // Set the state to began and reset tapStartTime
            tapStartTime = NSDate()
            
        // Otherwise, set the state to .Failed
        } else {
            state = .Failed
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        // If we still just have one touch, and we are in the .Possible state
        if touches.count == 1  && state == .Possible {
            
            // Set the state to began and reset tapStartTime
            var tapEndTime = NSDate()
            
            // If the elapsed time between the start of the tap and the end of 
            // the tap is less than maximumTapDuration, set state to 
            // .Recognized
            let elapsedTime = tapEndTime.timeIntervalSinceDate(tapStartTime)
            if elapsedTime < maximumTapDuration {
                state = .Recognized
                reset()
            }
            
            // Otherwise, set the state to .Failed
        } else {
            state = .Failed
        }
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
    }
}

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

class BBUIGestureRecognizer: Equatable {
    private var state: BBUIGestureRecognizerState = .BBUIGestureRecognizerStatePossible
    private var cancelsTouchesInView = true
    private var delaysTouchesBegan = false
    private var delaysTouchesEnded = true
    private var enabled = true
    
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
        println("touchesBegan in recognizer on node: \(_node!)")
    }
}

func ==(lhs: BBUIGestureRecognizer, rhs: BBUIGestureRecognizer) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

// http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/
// https://github.com/BigZaphod/Chameleon/blob/master/UIKit/Classes/UIGestureRecognizer.m

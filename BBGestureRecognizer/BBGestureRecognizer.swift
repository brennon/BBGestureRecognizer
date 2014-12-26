//
//  BBGestureRecognizer.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/23/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import UIKit
import SpriteKit

protocol BBGestureRecognizerTargetAction {
    func performAction(gestureRecognizer: BBGestureRecognizer?)
}

struct BBGestureRecognizerTargetActionWrapper<T: AnyObject> : BBGestureRecognizerTargetAction {
    weak var target: T?
    let action: (T) -> (BBGestureRecognizer?) -> ()
    
    func performAction(gestureRecognizer: BBGestureRecognizer?) -> () {
        if let t = target {
            action(t)(gestureRecognizer)
        }
    }
}

enum BBGestureRecognizerState: Int {
    case BBGestureRecognizerStatePossible
    case BBGestureRecognizerStateBegan
    case BBGestureRecognizerStateChanged
    case BBGestureRecognizerStateEnded
    case BBGestureRecognizerStateCancelled
    case BBGestureRecognizerStateFailed
    case BBGestureRecognizerStateRecognized
}

class BBGestureRecognizer {
    private var state: BBGestureRecognizerState = .BBGestureRecognizerStatePossible
    private var cancelsTouchesInView = true
    private var delaysTouchesBegan = false
    private var delaysTouchesEnded = true
    private var enabled = true
    
    private var _node: SKNode? = nil
    private(set) var node: SKNode? {
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
    
    private var registeredAction: BBGestureRecognizerTargetAction?
    private var trackingTouches = [UITouch]()
    
    init<T: AnyObject>(target: T, action: (T) -> (BBGestureRecognizer?) -> ()) {
        addTarget(target, action: action)
    }
    
    func addTarget<T: AnyObject>(target: T, action: (T) -> (BBGestureRecognizer?) -> ()) {
        let targetAction = BBGestureRecognizerTargetActionWrapper(target: target, action: action)
        registeredAction = targetAction
    }
    
    func removeTarget() {
        registeredAction = nil
    }
    
    func reset() {
        state = .BBGestureRecognizerStatePossible
    }
}

// http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/
// https://github.com/BigZaphod/Chameleon/blob/master/UIKit/Classes/UIGestureRecognizer.m

//
//  BBGestureRecognizer.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/23/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import UIKit

protocol TargetAction {
    func performAction()
}

struct TargetActionWrapper<T: AnyObject> : TargetAction {
    weak var target: T?
    let action: (T) -> () -> ()
    
    func performAction() -> () {
        if let t = target {
            action(t)()
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

typealias BBGestureRecognizerAction = (BBGestureRecognizer?) -> ()

class BBGestureRecognizer {
    private var state: BBGestureRecognizerState = .BBGestureRecognizerStatePossible
    private var cancelsTouchesInView = true
    private var delaysTouchesBegan = false
    private var delaysTouchesEnded = true
    private var enabled = true
    
    private var registeredActions = [(AnyObject, BBGestureRecognizerAction)]()
    private var trackingTouches = [UITouch]()
    
    init(target: AnyObject, action: (BBGestureRecognizer?) -> ()) {
        
    }
    
    func addTarget(target: AnyObject, action: BBGestureRecognizerAction) {
        let actionPair = (target, action)
        registeredActions.append(actionPair)
        println("registeredActions: \(registeredActions)")
    }
    
    func removeTarget(target: AnyObject, action: BBGestureRecognizerAction) {
        let actionPair = (target, action)
        if let index = find(registeredActions, actionPair) {
            registeredActions.removeAtIndex(index)
        }
        println("registeredActions: \(registeredActions)")
    }
}

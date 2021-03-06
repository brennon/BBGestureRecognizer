//
//  BBGestureRecognizer.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/23/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import UIKit
import SpriteKit

/**
    Types that conform to the `BBGestureRecognizerargetAction` protocol can be assigned to the `registeredAction` property of a 
    `BBGestureRecognizer`.
*/
protocol BBGestureRecognizerTargetAction {
    
    /**
        `performAction:` will be called when the associated gesture recognizer either recognizes a discrete gesture, or observes 
        a change in a continuous gesture.
    
        :param: gestureRecognizer The `BBGestureRecognizer` instance that has recognized a gesture.
    */
    func performAction(gestureRecognizer: BBGestureRecognizer?)
}

/**
    A `BBGestureRecognizerTargetActionWrapper` wraps both a target instance of any class and a method to be called on that 
    instance. `BBGestureRecognizerTargetActionWrapper` conforms to the `BBGestureRecognizerTargetAction` protocol, and an 
    instance of a `BBGestureRecognizerTargetActionWrapper` is meant to be used as the `registeredAction` on a 
    `BBGestureRecognizer`.
*/
struct BBGestureRecognizerTargetActionWrapper<T: AnyObject>: BBGestureRecognizerTargetAction {
    
    // MARK: Properties
    
    /// The target instance of some class.
    weak var target: T?
    
    /// The method to be called on `target`.
    let action: (T) -> (BBGestureRecognizer?) -> ()
    
    // MARK: BBGestureRecognizerTargetAction Protocol
    
    /**
        Calls `action` on `target`.
    
        :param: gestureRecognizer The `BBGestureRecognizer` that is calling this method.
    */
    func performAction(gestureRecognizer: BBGestureRecognizer?) -> () {
        if let t = target {
            action(t)(gestureRecognizer)
        }
    }
}

/// All possible states for a `BBGestureRecognizer`.
enum BBGestureRecognizerState: Int, Printable {
    case Possible
    case Began
    case Changed
    case Ended
    case Cancelled
    case Failed
    case Recognized
    
    var description: String {
        switch(self) {
        case Possible:
            return "Possible"
        case Began:
            return "Began"
        case Changed:
            return "Changed"
        case Ended:
            return "Ended"
        case Cancelled:
            return "Cancelled"
        case Failed:
            return "Failed"
        case Recognized:
            return "Recognized"
        }
    }
}

/// A representation of a state transition on a `BBGestureRecognizer`.
struct BBGestureRecognizerStateTransition {
    let fromState: BBGestureRecognizerState
    let toState: BBGestureRecognizerState
    let shouldNotify: Bool
}

// MARK: - BBGestureRecognizer

/**
    `BBGestureRecognizer` is a base class for concrete gesture-recognizer classes that can be attached to `SKNode` instances. A 
    gesture recognizer object--or, simply, a gesture recognizer--decouples the logic for recognizing a gesture and acting on that 
    recognition. When one of these objects recognizes a common gesture or, in some cases, a change in the gesture, it sends an 
    action message to each designated target object.
    <br /><br />
    The `BBGestureRecognizer` class defines a set of common behaviors that can be configured for subclassed gesture 
    recognizers. It can also communicate with its delegate (an object that conforms to the `BBGestureRecognizerDelegate` 
    protocol), thereby enabling finer-grained customization of some behaviors.
    <br /><br />
    A gesture recognizer operates on touches hit-tested to a specific `SKNode` and all of that node's descendant nodes. It thus 
    must be associated with that view. To make that association you must call the `SKNode` method `addGestureRecognizer:`.
    <br /><br />
    A gesture recognizer has a method associated with it. Recognition of a gesture results in calling this method. The action 
    method must conform to the signature: `(BBGestureRecognizer?) -> ()`
    <br /><br />
    Beyond this, a `BBGestureRecognizer` operates much like a `UIGestureRecognizer`. See the documentation for 
    `UIGestureRecognizer` for further information.
*/
class BBGestureRecognizer: Hashable, Printable {
    
    var name = ""
    
    // MARK: Properties
    
    /**
        The `UITouch` objects that the gesture recognizer is currently tracking. For simplicity, `beginTrackingTouch(_:)` is the 
        only place where touches are added to this array, and `endTrackingTouch(_:)` is the only place where touches are removed 
        from this array.
    */
    private var trackingTouches = [UITouch]()
    
    /**
        The `UITouch` objects that the gesture recognizer is currently ignoring. For simplicity, `ignoreTouch(_:forEvent:)` is 
        the only place where touches are added to this array, and `endTrackingTouch(_:)` is the only place where touches are 
        removed from this array.
    */
    private var ignoredTouches = [UITouch]()
    
    // MARK: Initializing a Gesture Recognizer
    
    /**
        Initializes an allocated gesture-recognizer object with a target and an action selector. This method is the designated 
        initializer.
    
        :param: target An object on which a method will be called when this gesture recognizer recognizes a gesture. `nil` is not 
            a valid value.
        :param: action A method implemented by the target to handle the gesture recognized by the receiver. The method must 
            conform to the signature described in the class overview. `nil` is not a valid value.
    */
    init<T: AnyObject>(target: T, action: (T) -> (BBGestureRecognizer?) -> ()) {
        let targetAction = BBGestureRecognizerTargetActionWrapper(
            target: target,
            action: action
        )
        registeredAction = targetAction
    }
    
    // MARK: Getting the Recognizer's Associated Action
    
    /// The `BBGestureRecognizerTargetAction` on which `performAction:` will be called when a gesture is recognized.
    private var registeredAction: BBGestureRecognizerTargetAction?
    
    // MARK: Getting the Touches and Location of a Gesture
    
    /**
        Returns the point computed as the location in a given node of the gesture represented by the receiver. The returned value 
        is a generic single-point location for the gesture computed by the UIKit framework. It is usually the centroid of the 
        touches involved in the gesture.
        
        :param: node An `SKNode` object on which the gesture took place. Specify `nil` to indicate the gesture's node's scene.
    
        :returns: A point in the local coordinate system of `node` that identifies the location of the gesture. If `nil` is 
            specified for `node`, the method returns the gesture location in the gesture's node's scene's base coordinate system.
    */
    func locationInNode(node: SKNode?) -> CGPoint? {
        
        var actualNode = node
        
        // If node was nil, look for the scene
        if actualNode == nil {
            
            actualNode = self.node?.scene? as SKNode?
        }
        
        assert(actualNode != nil, "Passed nil to locationInNode(_:), but the gesture recognizer's node's scene was also nil.")
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var n: CGFloat = 0
        
        for touch in trackingTouches {
            let point = touch.locationInNode(node)
            x += point.x
            y += point.y
            n++
        }
        
        if n > 0 {
            return CGPointMake(x / n, y / n)
        } else {
            return nil
        }
    }
    
    /**
        Returns the location of one of the gesture's touches in the local coordinate system of a given node.
        
        :param: touchIndex The index of a `UITouch` object in a private array maintained by the gesture recognizer. This touch 
            object represents a touch of the current gesture.
        :param inNode An `SKNode` object on which the gesture took place. Specify `nil` to indicate the gesture's node's scene.
        
        :returns: A point in the local coordinate system of `node` that identifies the location of the touch. If `nil` is 
            specified for `node`, the method returns the touch location in the gesture's node's scene's base coordinate system.
    */
    func locationOfTouch(touchIndex index: Int, inNode node: SKNode?) -> CGPoint {
        return trackingTouches[index].locationInNode(node)
    }

    /**
        Returns the number of touches involved in the gesture represented by the receiver. Using the value returned by this 
        method in a loop, you can ask for the location of individual touches using the `locationOfTouch(_:inView:)` method.
    
        :returns: The number of `UITouch` objects in a private array maintained by the gesture recognizer. Each of these objects 
            represents a touch in the current gesture.
    */
    func numberOfTouches() -> Int {
        return trackingTouches.count
    }

    // MARK: Getting the Recognizer's State and Node
    
    /**
        The state to which this gesture recognizer will next advance. Under the hood, when a `BBGestureRecognizer` sets 
        `state`, it is actually `nextState` that receives this update. Then, when the coordinating object processes all gesture 
        recognizers on a node (this object is typically the node itself), it advances each recognizer from `state` to the new 
        state in `nextState`. This allows the coordinating object to enforce dependencies between gesture recognizers. In doing 
        so, the coordinating object can potentially change `nextState` to a new, appropriate value, and then advance the `state` 
        on all recognizers by calling its `advanceState()` method.
    */
    internal var nextState: BBGestureRecognizerState? = nil
    
    /// Private storage for the `state` property.
    private var _state: BBGestureRecognizerState = .Possible
    
    /**
        The current `BBGestureRecognizerState` of the gesture recognizer. When `state` transitions from `.Possible` to `.Began` 
        or `.Recognized` and the `delegate` (if set) prevents the gesture recognizer from beginning, `state` is automatically set 
        to `.Failed`. Otherwise, `state` is only updated if the transition is allowed (see `allowedStateTransitions`). Lastly, if 
        the allowed transition (if found) has `shouldNotify` set to `true`, the gesture recognizer's associated action method is 
        called.
    */
    internal(set) var state: BBGestureRecognizerState {
        get {
            return _state
        }
        set {
            nextState = newValue
        }
    }
    
    /**
        Advances the gesture recognizer's state from `state` to `nextState`. See `nextState` for more information on when and why 
        this is necessary.
    */
    internal func advanceState() {
        
        // If there is a state in nextState to which we should advance
        if var varNewState = nextState {
        
            // If there is a delegate and it says that this recognizer should not begin, return immediately.
            if let actualDelegate = delegate {
                if _state == .Possible {
                    if nextState == .Began || nextState == .Recognized {
                        if !actualDelegate.gestureRecognizerShouldBegin(self) {
                            return
                        }
                    }
                }
            }
            
            // Check gesture recognizers on which this gesture is dependent.
            var requestedAnyUpdatesFromPendingRecognizers = false
            for recognizer in recognizersRequiredToFail {

                // If this recognizer is in the .Possible state and the other recognizer is in or transitioning to .Began or 
                // .Recognized, this recognizer should transition to .Failed. If this is the case, we can break out of this loop.
                if _state == .Possible || _state == .Recognized {
                    if recognizerIsRecognizing(recognizer) {
                        println("Failing \(name) because \(recognizer.name) is recognizing")
                        varNewState = .Failed
                        break
                    }
                }
                
                // If the other recognizer has scheduled a transition to a terminal state, we need to not change state here, tell 
                // the other recognizer that we are waiting for an update, return immediately, and wait for that update.
                if recognizer.terminalStateIsPending {
                    
                    // If we haven't already requested an update from the other recognizer, request one.
                    if find(recognizer.failureDependents, self) == nil {
                        recognizer.addFailureDependent(self)
                        requestedAnyUpdatesFromPendingRecognizers = true
                    }
                }
            }
            
            // If we requested any updates from recognizers wih a pending terminal state, don't update state and return.
            if requestedAnyUpdatesFromPendingRecognizers {
                return
            }
            
            // If the transition from _state to nextState is allowed...
            let (allowedTransition, shouldNotify) = findAllowedTransition(_state, toState: varNewState)
            
            if allowedTransition {
                
                // Decide if the recognizer should reset based on the transition.
                var shouldResetOnNextRunLoop: Bool
                switch varNewState {
                case .Recognized, .Cancelled, .Ended, .Failed:
                    shouldResetOnNextRunLoop = true
                default:
                    shouldResetOnNextRunLoop = false
                }
                
                // The docs mention that the action messages are sent on the next run loop, so we'll do that here. Note that 
                // this means that reset can't happen until the next run loop, either, otherwise the state property is going 
                // to be wrong when the action handler looks at it, so as a result we also delay the reset call (if 
                // necessary) in continueTrackingWithEvent:.
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    
                    self._state = varNewState
                    self.nextState = nil
                    
                    if shouldNotify {
                        self.registeredAction?.performAction(self)
                    }
                    
                    if shouldResetOnNextRunLoop {
                        self.reset()
                    }
                }
            } else {
                
                println(
                    "Invalid state transition in \(name) from \(_state) to \(varNewState)"
                )
            }
        }
    }
    
    func recognizerIsRecognizing(recognizer: BBGestureRecognizer) -> Bool {
        var isRecognizing = false

        switch recognizer.state {
        case .Began, .Recognized, .Changed:
            isRecognizing = true
        default:
            break
        }

        if let unwrappedNextState = recognizer.nextState {
            switch unwrappedNextState {
            case .Began, .Recognized, .Changed:
                isRecognizing = true
            default:
                break
            }
        }
        
        return isRecognizing
    }
    
    var pendingTerminalState: BBGestureRecognizerState?
    var terminalStateIsPending: Bool {
        return pendingTerminalState != nil
    }
    
    func schedulePendingRecognition(withState: BBGestureRecognizerState, andDelay delay: NSTimeInterval) {
        pendingTerminalState = withState
        
        let delayInNanoseconds = delay * NSTimeInterval(NSEC_PER_SEC)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInNanoseconds))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            if self.pendingTerminalState != nil {
            
                self.state = self.pendingTerminalState!
                
                // Inform failure dependent recognizers of change in state
                for dependentRecognizer in self.failureDependents {
                    dependentRecognizer.failureDependencyResolved(self, withState: self.pendingTerminalState!)
                }
                
                self.pendingTerminalState = nil
                self.advanceState()
            }
        }
    }
    
    func updatePendingRecognition(withState: BBGestureRecognizerState) {
        pendingTerminalState = withState
    }
    
    /// Private storage for the `node` property.
    private var _node: SKNode? = nil
    
    /**
        The `SKNode` to which this `BBGestureRecognizer` is attached. You attach (or add) a gesture recognizer to an `SKNode` 
        object using its `addGestureRecognizer(_:)` method. When `node` is set, `reset` is called on the recognizer.
    */
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
    
    // FIXME: State should transition to .Cancelled if enabled is set to false while recognition is in progress.
    
    /**
        A Boolean property that indicates whether the gesture recognizer is 
        enabled. Disables a gesture recognizers so it does not receive touches. 
        The default value is `true`. If you change this property to `false` 
        while a gesture recognizer is currently recognizing a gesture, the 
        gesture recognizer transitions to a cancelled state.
    */
    var enabled = true
    
    // MARK: Canceling and Delaying Touches
    
    // FIXME: Implement cancelsTouchesInView
//    var cancelsTouchesInView = true
    
    // FIXME: Implement delaysTouchesBegan
//    var delaysTouchesBegan = false
    
    // FIXME: Implement delaysTouchesEnded
//    var delaysTouchesEnded = true
    
    // MARK: Specifying Dependencies Between Gesture Recognizers
    
    /**
        An array of other `BBGestureRecognizer` instances that must fail in order for this gesture recognizer to recognize its 
        gesture.
    */
    internal var recognizersRequiredToFail = [BBGestureRecognizer]()
    
    /**
        Creates a dependency relationship between the gesture recognizer on which this method was called and another gesture 
        recognizer. This method creates a relationship with another gesture recognizer that delays the receiver's transition out 
        of the `.Possible` state. The state that the receiver transitions to depends on what happens with 
        `otherGestureRecognizer`. If `otherGestureRecognizer` transitions to the `.Failed` state, the receiver transitions to its 
        normal next state. If `otherGestureRecognizer` transitions to the `.Recognized` or `.Began` state, the receiver 
        transitions to `.Failed`. An example where this method might be called is when you want a single-tap gesture require that 
        a double-tap gesture fail.
    
        :param: otherGestureRecognizer Another gesture-recognizer object (an instance of a subclass of `BBGestureRecognizer`).
    */
    func requireGestureRecognizerToFail(otherGestureRecognizer: BBGestureRecognizer) {
        if find(recognizersRequiredToFail, otherGestureRecognizer) == nil {
            recognizersRequiredToFail.append(otherGestureRecognizer)
        }
    }
    
    private var failureDependents = [BBGestureRecognizer]()
    
    private func addFailureDependent(dependentRecognizer: BBGestureRecognizer) {
        if find(failureDependents, dependentRecognizer) == nil {
            failureDependents.append(dependentRecognizer)
        }
    }
    
    private func removeFailureDependent(recognizer: BBGestureRecognizer) {
        if let index = find(failureDependents, recognizer) {
            failureDependents.removeAtIndex(index)
        }
    }
    
    private func failureDependencyResolved(resolvingRecognizer: BBGestureRecognizer, withState state: BBGestureRecognizerState) {
        resolvingRecognizer.removeFailureDependent(self)
        
        switch state {
        case .Began, .Changed, .Recognized, .Ended:
            self.state = .Failed
        default:
            break
        }
        
        advanceState()
    }
    
    // FIXME: Implement canPreventGestureRecognizer(_:)
//    func canPreventGestureRecognizer(preventedGestureRecognizer: BBGestureRecognizer) -> Bool {}
    
    // FIXME: Implement canBePreventedByGestureRecognizer(_:)
//    func canBePreventedByGestureRecognizer(preventingGestureRecognizer: BBGestureRecognizer) -> Bool {}
    
    // FIXME: Implement shouldRequireFailureOfGestureRecognizer(_:)
//    func shouldRequireFailureOfGestureRecognizer(otherGestureRecognizer: BBGestureRecognizer) -> Bool {}
    
    // FIXME: Implement shouldBeRequiredToFailByGestureRecognizer(_:)
//    func shouldBeRequiredToFailByGestureRecognizer(otherGestureRecognizer: BBGestureRecognizer) -> Bool {}
    
    // MARK: Setting and Getting the Delegate
    
    /**
        The delegate of the gesture recognizer. The gesture recognizer maintains a weak reference to its delegate. The delegate 
        must adopt the `BBGestureRecognizerDelegate` protocol and implement all of its methods.
    */
    weak var delegate: BBGestureRecognizerDelegate? = nil
    
    // MARK: Methods For Subclasses
    
    /**
        Sent to the receiver when one or more fingers touch down in the associated view. This method has the same exact signature 
        as the corresponding one declared by `UIResponder`. Through this method a gesture recognizer receives touch objects (in 
        their `.Began` phase) before the node attached to the gesture recognizer receives them. `BBGestureRecognizer` objects 
        are not in the responder chain, yet observe touches hit-tested to their node and their node's descendants. After 
        observation, the delivery of touch objects to the attached view, or their disposition otherwise, is affected by the 
        `cancelsTouchesInView`, `delaysTouchesBegan`, and `delaysTouchesEnded` properties.
        <br /><br />
        If the gesture recognizer is interpreting a continuous gesture, it should set its state to `.Began` upon receiving this 
        message. If at any point in its handling of the touch objects the gesture recognizer determines that the multi-touch 
        event sequence is not its gesture, it should set it state to `.Cancelled`.
    
        :param: touches A set of `UITouch` instances in the event represented by `event` that represent the touches in the 
            `.Began` phase.
        :param: event A `UIEvent` object representing the event to which the touches belong.
    */
    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {}
    
    /**
        Sent to the receiver when one or more fingers touch down in the associated view. This method has the same exact signature 
        as the corresponding one declared by `UIResponder`. Through this method a gesture recognizer receives touch objects (in 
        their `.Moved` phase) before the node attached to the gesture recognizer receives them. `BBGestureRecognizer` objects 
        are not in the responder chain, yet observe touches hit-tested to their node and their node's descendants. After 
        observation, the delivery of touch objects to the attached view, or their disposition otherwise, is affected by the 
        `cancelsTouchesInView`, `delaysTouchesBegan`, and `delaysTouchesEnded` properties.
        <br /><br />
        If the gesture recognizer is interpreting a continuous gesture, it should set its state to `.Changed` upon receiving this 
        message. If at any point in its handling of the touch objects the gesture recognizer determines that the multi-touch 
        event sequence is not its gesture, it should set it state to `.Cancelled`.
    
        :param: touches A set of `UITouch` instances in the event represented by `event` that represent the touches in the 
            `.Began` phase.
        :param: event A `UIEvent` object representing the event to which the touches belong.
    */
    func touchesMoved(touches: NSSet, withEvent event: UIEvent) {}
    
    /**
        Sent to the receiver when one or more fingers touch down in the associated view. This method has the same exact signature 
        as the corresponding one declared by `UIResponder`. Through this method a gesture recognizer receives touch objects (in 
        their `.Ended` phase) before the node attached to the gesture recognizer receives them. `BBGestureRecognizer` objects 
        are not in the responder chain, yet observe touches hit-tested to their node and their node's descendants. After 
        observation, the delivery of touch objects to the attached view, or their disposition otherwise, is affected by the 
        `cancelsTouchesInView`, `delaysTouchesBegan`, and `delaysTouchesEnded` properties.
        <br /><br />
        If the gesture recognizer is interpreting a continuous gesture, it should set its state to `.Ended` upon receiving this 
        message. If it is interpreting a discrete gesture, it should set its state to `.Recognized`. If at any point in its 
        handling of the touch objects the gesture recognizer determines that the multi-touch event sequence is not its gesture, 
        it should set it state to `.Cancelled`.
        
        :param: touches A set of `UITouch` instances in the event represented by `event` that represent the touches in the 
            `.Began` phase.
        :param: event A `UIEvent` object representing the event to which the touches belong.
    */
    func touchesEnded(touches: NSSet, withEvent event: UIEvent) {}
    
    /**
        Sent to the receiver when one or more fingers touch down in the associated view. This method has the same exact signature 
        as the corresponding one declared by `UIResponder`. Through this method a gesture recognizer receives touch objects (in 
        their `.Cancelled` phase) before the node attached to the gesture recognizer receives them. `BBGestureRecognizer` 
        objects are not in the responder chain, yet observe touches hit-tested to their node and their node's descendants. After 
        observation, the delivery of touch objects to the attached view, or their disposition otherwise, is affected by the 
        `cancelsTouchesInView`, `delaysTouchesBegan`, and `delaysTouchesEnded` properties.
        <br /><br />
        Upon receiving this message, the gesture recognizer for a continuous  gesture should set its state to `.Cancelled`; a 
        gesture recognizer for a discrete gesture should set its state to `.Failed`.
        
        :param: touches A set of `UITouch` instances in the event represented by `event` that represent the touches in the 
            `.Began` phase.
        :param: event A `UIEvent` object representing the event to which the touches belong.
    */
    func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {}
    
    // FIXME: Make sure reset is called in all of the below listed scenarios
    // FIXME: Make last sentence of below comment is implemented
    
    /**
        Overridden to reset internal state when a gesture recognition attempt completes. The runtime calls this method after the 
        gesture-recognizer state has been set to `.Ended`, `.Recognized`, `.Cancelled`, or `.Failed`--in other words, any of the 
        terminal states for a gesture recognition attempt. Subclasses should reset any internal state in preparation for a new 
        attempt at gesture recognition. After this method is called, the gesture recognizer receives no further updates for 
        touches that have begun but haven't ended.
    */
    func reset() {
        _state = .Possible
        
        // Ignore all remaining touches
        for touch in trackingTouches {
            ignoreTouch(touch, forEvent: nil)
        }
    }
    
    /**
        Tells the gesture recognizer to ignore a specific touch of the given event. If a touch isn't part of this gesture you may 
        pass it to this method, causing it to be ignored. `BBGestureRecognizer` does not cancel ignored touches on the 
        associated view even if `cancelsTouchesInView` is `true`. This method is intended to be called, not overridden.
    
        :param: touch A `UITouch` object that is part of the current multi-touch sequence and associated with `event`.
        :param: event A `UIEvent?` object that, if not `nil`, includes a reference to `touch`.
    */
    func ignoreTouch(touch: UITouch, forEvent event: UIEvent?) {
        ignoredTouches.append(touch)
    }
    
    // MARK: Internal/Private Methods
    
    /**
        Begin tracking each touch in the provided array. New touches are sent to the gesture recognizer through this method. 
        These touches are added to a private internal array that is used as the gesture recognizer continues to track the touches.
    
        :param: touches An array of `UITouch` instances that the gesture recognizer should begin tracking.
    */
    internal func beginTrackingTouches(touches: [UITouch]) {
        for touch in touches {
            beginTrackingTouch(touch)
        }
    }
    
    /**
        Begin tracking a single touch.
    
        :param: touch The `UITouch` instance that the gesture recognizer should begin tracking.
    */
    private func beginTrackingTouch(touch: UITouch) {
        
        // If this recognizer is enabled
        if enabled {
            
            // If there is no delegate or the delegate says this recognizer should receive this touch, add this touch to 
            // trackingTouches.
            var shouldReceiveTouch = true
            if let actualDelegate = delegate {
                shouldReceiveTouch = actualDelegate.gestureRecognizer(
                    self,
                    shouldReceiveTouch: touch
                )
            }
            
            if shouldReceiveTouch {
                trackingTouches.append(touch)
            }
        }
    }
    
    /**
        Continue tracking each of the currently tracked touches. For each `UITouch` in `trackingTouches`, this method will check 
        the phase of the touch, and distribute it to the correct 'handler' method (`touchesBegan(_:withEvent:)`, etc.) This 
        method also calls `reset()` if all touches have either ended or been cancelled.
    
        :param: touches An array of `UITouch` instances that the gesture recognizer should begin tracking.
    */
    internal func continueTrackingTouchesWithEvent(event: UIEvent) {
        
        // Subtract ignoredTouches from trackingTouches.
        var trackingTouchesExcludingIgnoredTouches = [UITouch]()
        
        for touch in trackingTouches {
            let index = find(ignoredTouches, touch)
            if index == nil {
                trackingTouchesExcludingIgnoredTouches.append(touch)
            }
        }
        
        var began = NSMutableSet()
        var moved = NSMutableSet()
        var ended = NSMutableSet()
        var cancelled = NSMutableSet()
        
        var multitouchSequenceIsEnded = true

        for touch in trackingTouchesExcludingIgnoredTouches {
            switch touch.phase {
            case .Began:
                multitouchSequenceIsEnded = false
                began.addObject(touch)
            case .Moved:
                multitouchSequenceIsEnded = false
                moved.addObject(touch)
            case .Stationary:
                multitouchSequenceIsEnded = false
            case .Ended:
                ended.addObject(touch)
            case .Cancelled:
                cancelled.addObject(touch)
            }
        }
        
        switch state {
        case .Possible,
             .Began,
             .Changed:
            
            if began.count > 0 {
                touchesBegan(began, withEvent: event)
            }
            
            if moved.count > 0 {
                touchesMoved(moved, withEvent: event)
            }
            
            if ended.count > 0 {
                touchesEnded(ended, withEvent: event)
            }
            
            if cancelled.count > 0 {
                touchesCancelled(cancelled, withEvent: event)
            }
        default:
            break
        }

//        // If all the touches are ended or cancelled, then the multitouch sequence must be over--so we can reset our state back 
//        // to normal and clear all the tracked touches, etc. to get ready for a new touch sequence in the future. This also 
//        // applies to the special discrete gesture events because those events are only sent once.
//        if multitouchSequenceIsEnded && pendingTerminalState == nil {
//            
//            // See note above in state setter about the delay here.
//            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0))
//            dispatch_after(delayTime, dispatch_get_main_queue()) {
//                self.reset()
//            }
//        }
    }
    
    /**
        End tracking of a single touch.
    
        :param: touch The `UITouch` instance that the gesture recognizer should stop tracking.
    */
    private func endTrackingTouch(touch: UITouch) {
        
        // Remove touch from trackingTouches.
        if let index = find(trackingTouches, touch) {
            trackingTouches.removeAtIndex(index)
        }
        
        // Remove touch from ignoredTouches.
        if let index = find(ignoredTouches, touch) {
            ignoredTouches.removeAtIndex(index)
        }
    }
    
    /**
        End tracking of each touch in the provided array.
    
        :param: touches An array of `UITouch` instances that the gesture recognizer should stop tracking.
    */
    internal func endTrackingTouches(touches: [UITouch]) {
        for touch in touches {
            endTrackingTouch(touch)
        }
    }
    
    /**
        Determines if a transition from one `BBGestureRecognizerState` to another is allowed.
        
        :param: fromState The beginning state of the transition.
        :param: toState The ending state of the transition.
        
        :returns: Returns `(allowed: Bool, shouldNotify: Bool)` where `allowed` indicates if the transition is allowed and 
            `shouldNotify` indicates if the recognizer's action method should be called.
    */
    private func findAllowedTransition(fromState: BBGestureRecognizerState, toState: BBGestureRecognizerState) ->
        (alowed: Bool, shouldNotify: Bool) {
        
        switch fromState {
        case .Possible:
            switch toState {
            case .Recognized, .Began:
                return (true, true)
            case .Failed:
                return (true, false)
            default:
                break
            }
        case .Began, .Changed:
            switch toState {
            case .Changed, .Cancelled, .Ended:
                return (true, true)
            default:
                break
            }
        default:
            break
        }
        
        return (false, false)
    }
    
    // MARK: Printable Protocol
    
    /**
        Textual representation of the `BBGestureRecognizer`.
    */
    internal var description: String {
        var stateString: String
        
        switch (state) {
        case .Possible:
            stateString = "Possible"
        case .Began:
            stateString = "Began"
        case .Changed:
            stateString = "Changed"
        case .Ended:
            stateString = "Ended"
        case .Cancelled:
            stateString = "Cancelled"
        case .Failed:
            stateString = "Failed"
        case .Recognized:
            stateString = "Recognized"
        }
        
        let thisType = ObjectIdentifier(self)
        return "<BBGestureRecognizer; state = \(stateString); node = \(node)>"
    }
    
    // MARK: Hashable Protocol
    
    /**
        The hash value of the gesture recognizer.
    */
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

// MARK: BBGestureRecognizer Equatable Protocol

/**
    Compare two `BBGestureRecognizer` instances for equality.

    :param: lhs An instance of a `BBGestureRecognizer`.
    :param: rhs Another instance of a `BBGestureRecognizer`.

    :returns: Returns `true` if `lhs` and `rhs` are the same instance of a `BBGestureRecognizer`. Otherwise, it returns `false`.
*/
func ==(lhs: BBGestureRecognizer, rhs: BBGestureRecognizer) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

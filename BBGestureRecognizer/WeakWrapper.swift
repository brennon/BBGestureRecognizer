//
//  WeakWrapper.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/30/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

struct WeakWrapper<T: AnyObject> {
    weak private var value: T?
    
    init(value: T) {
        self.value = value
    }
    
    func get() -> T? {
        return value
    }
}

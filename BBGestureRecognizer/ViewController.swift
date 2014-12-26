//
//  ViewController.swift
//  BBGestureRecognizer
//
//  Created by Brennon Bortz on 12/23/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let skView = self.view as SKView
        skView.showsDrawCount = true
        skView.showsNodeCount = true
        skView.showsFPS = true
    }
    
    override func viewWillAppear(animated: Bool) {
        let testScene = TestScene(size: CGSizeMake(768, 1024))
        let skView = self.view as SKView
        skView.presentScene(testScene)
    }
    
    func doSomething(gestureRecognizer: BBUIGestureRecognizer?) {
        println("doing something")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


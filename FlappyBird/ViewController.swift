//
//  ViewController.swift
//  FlappyBird
//
//  Created by 畑中 彩里 on 2020/04/22.
//  Copyright © 2020 sari.hatanaka. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
        
        //skViewに型変換する
        let skView = self.view as! SKView
        //FPSを表示する
        skView.showsFPS = true
        //ノードの数を表示する
        skView.showsNodeCount = true
        let scene = GameScene(size:skView.frame.size)
        
        skView.presentScene(scene)
    
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }

}


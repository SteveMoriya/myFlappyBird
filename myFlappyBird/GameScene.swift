//
//  GameScene.swift
//  myFlappyBird
//
//  Created by steve on 17/08/2017.
//  Copyright © 2017 steve. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    //在当前场景被显示到一个view上的时候调用，可以在这个方法中做初始化工作
    override func didMove(to view: SKView) {
        
        //设置场景的背景颜色为淡蓝色
        self.backgroundColor = SKColor(red:80.0/255.0, green:192.0/255.0, blue:203.0/255.0,alpha: 1.0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

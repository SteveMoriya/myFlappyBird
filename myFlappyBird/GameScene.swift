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
    
    // MARK:  2.布置场景和游戏状态
    
    //添加两个地面的变量
    //布置场景和游戏状态
    var floor1:SKSpriteNode!
    var floor2:SKSpriteNode!
    
    /*
     注：
     添加两个floor头尾相连，让floor向左移动
     两个floor循环出现，给人一种小鸟在动的感觉
     
     anchorPoint指代相对于自身位置
     position指代相对于父级视图位置
     
     SKScene场景的默认锚点为(0,0)即左下角，SKSpriteNode的默认锚点为(0.5,0.5)即它的中心点
     另外SpriteKit的坐标系是向右X增加，向上y增加。
     iOS应用中的UIKit是向右X增加，向下y增加!
     */
    
    //放置小鸟
    var bird:SKSpriteNode!
    
    /*
     游戏状态
     1,一开始小鸟在屏幕中间飞，地面在移动，游戏还未开始,水管不会出现
     2,玩家准备好，并点击屏幕开始。小鸟受到重力作用向下坠落，水管也出现。每一次点击屏幕小鸟上升一点
     3,如果小鸟碰到水管或者碰到地面，游戏结束。小鸟停止飞行，场景里的水管和地面都不动。
     */
    enum GameStatus {
        case idle //初始化
        case running //游戏运行中
        case over //游戏结束
    }
    
    
    var gameStatus:GameStatus = .idle //表示当前游戏状态的变量，初始值为初始状态
    
    /*
     游戏会有三个进程状态，给GameScene增加三个对应的方法，分别处理这三个状态
     小鸟初始化位置放置游戏初始化方法中
     */
    func shuffle() {
        //游戏初始化方法
        gameStatus = .idle
        bird.position = CGPoint(x:self.size.width*0.5, y:self.size.height*0.5);
        
        birdStartFly()
    }
    
    func startGame() {
        //游戏开始处理方法
        gameStatus = .running
    }
    
    func gameOver() {
        //游戏结束处理方法
        gameStatus = .over
        
        birdStopFly()
    }
    
    
    //在当前场景被显示到一个view上的时候调用，可以在这个方法中做初始化工作
    override func didMove(to view: SKView) {
        
        //设置场景的背景颜色为淡蓝色
        self.backgroundColor = SKColor(red:80.0/255.0, green:192.0/255.0, blue:203.0/255.0,alpha: 1.0)
        
        
        floor1 = SKSpriteNode(imageNamed:"floor")
        floor1.anchorPoint = CGPoint(x:0,y:0)
        floor1.position = CGPoint(x:0,y:0)
        addChild(floor1)
        
        floor2 = SKSpriteNode(imageNamed:"floor")
        floor2.anchorPoint = CGPoint(x:0,y:0)
        floor2.position = CGPoint(x:floor1.size.width,y:0)
        addChild(floor2)
        
        bird = SKSpriteNode(imageNamed:"Bird0")
        addChild(bird)
        
        //场景初始化完成后，调用一下shuffle() 初始化游戏
        shuffle()
        
    }
    
    
    /*
     touchesBegan() 是 SKScene自带的系统方法，当玩家手指点击到屏幕上的时候调用
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameStatus {
            
            //如果在初始化状态下，玩家点击屏幕则开始游戏
        case .idle:
            startGame()
            
            //游戏运行内容
            //如果在游戏进行中状态下，玩家点击屏幕给小鸟一个向上的力
        case .running:
            print("给小鸟一个向上的力")
            
            
            //如果在游戏结束状态下，点击屏幕进入初始化状态
        case .over:
            shuffle()
        }
    }
    
    
    // MARK: 让内容动起来
    /*
     给GameScene 添加一个叫做moveScene()的方法，用来使场景内的物体向左移动起来，
     */
    
    func moveScene() {
        //make floor move
        floor1.position = CGPoint(x:floor1.position.x - 1, y:floor1.position.y)
        floor2.position = CGPoint(x:floor2.position.x - 1, y:floor2.position.y)
        
        if floor1.position.x < -floor1.size.width {
            floor1.position = CGPoint(x:floor2.position.x + floor2.size.width, y:floor1.position.y)
        }
        
        if floor2.position.x < -floor2.size.width {
            floor2.position = CGPoint(x:floor1.position.x + floor1.size.width, y:floor2.position.y)
        }
        
    }
    
    //添加小鸟飞方法
    func birdStartFly() {
        let flyAction = SKAction.animate(with: [SKTexture(imageNamed:"Bird0"),SKTexture(imageNamed:"Bird1"),SKTexture(imageNamed:"Bird2"),SKTexture(imageNamed:"Bird3"),SKTexture(imageNamed:"Bird2"),SKTexture(imageNamed:"Bird1"),SKTexture(imageNamed:"Bird0")], timePerFrame: 0.15)
        bird.run(SKAction.repeatForever(flyAction),withKey:"fly")
    }
    
    //停止飞
    func birdStopFly() {
        bird.removeAction(forKey: "fly")
    }
    
    
    /*
     update() 方法为SKScene自带的系统方法，在画面每一帧刷新的时候就会调用一次
     */
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if gameStatus != .over {
            moveScene()
        }
        
    }
}

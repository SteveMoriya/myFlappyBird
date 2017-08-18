//
//  GameScene.swift
//  myFlappyBird
//
//  Created by steve on 17/08/2017.
//  Copyright © 2017 steve. All rights reserved.
//

import SpriteKit

let birdCategory:UInt32 = 0x1 << 0
let pipeCategory:UInt32 = 0x1 << 1
let floorCategory: UInt32 = 0x1 << 2

class GameScene: SKScene  {
    
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
        removeAllPipesNode() //在每新的一局开始时，将之前的水管清空
        
        bird.position = CGPoint(x:self.size.width*0.5, y:self.size.height*0.5);
        
        bird.physicsBody?.isDynamic = false //设置初始状态下不受重力影响
        
        birdStartFly() //让鸟儿开始飞行
    }
    
    func startGame() {
        //游戏开始处理方法
        gameStatus = .running
        
        bird.physicsBody?.isDynamic = true //设置开始状态下受重力影响
        
        startCreateRandomPipesAction() //开始循环创建随机水管
    }
    
    func gameOver() {
        //游戏结束处理方法
        gameStatus = .over
        
        birdStopFly() //让鸟儿结束飞行
        
        stopCreateRandomPipesAction() //结束循环创建水管
    }
    
    
    //在当前场景被显示到一个view上的时候调用，可以在这个方法中做初始化工作
    override func didMove(to view: SKView) {
        
        //设置场景的背景颜色为淡蓝色
        self.backgroundColor = SKColor(red:80.0/255.0, green:192.0/255.0, blue:203.0/255.0,alpha: 1.0)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom:self.frame)
        //给场景添加一个物理体，这个物理题就是一条沿着场景四周的边，限制了游戏范围
        
        self.physicsWorld.contactDelegate = self as? SKPhysicsContactDelegate
        //物理世界的碰撞检测代理为场景自己
        //这样物理世界里面两个可以碰撞接触的物体碰到一起了，就会通知它的代理方法
        
        
        floor1 = SKSpriteNode(imageNamed:"floor")
        floor1.anchorPoint = CGPoint(x:0,y:0)
        floor1.position = CGPoint(x:0,y:0)
        addChild(floor1)
        
        //配置地面1的物理体
        floor1.physicsBody = SKPhysicsBody(edgeLoopFrom:CGRect(x:0, y:0, width:floor1.size.width, height:floor1.size.height))
        floor1.physicsBody?.categoryBitMask = floorCategory
        
        floor2 = SKSpriteNode(imageNamed:"floor")
        floor2.anchorPoint = CGPoint(x:0,y:0)
        floor2.position = CGPoint(x:floor1.size.width,y:0)
        addChild(floor2)
        
        //配置地面1的物理体
        floor2.physicsBody = SKPhysicsBody(edgeLoopFrom:CGRect(x:0, y:0, width:floor2.size.width, height:floor2.size.height))
        floor2.physicsBody?.categoryBitMask = floorCategory
        
        
        bird = SKSpriteNode(imageNamed:"Bird0")
        
        bird.physicsBody = SKPhysicsBody(texture:bird.texture!, size:bird.size)
        bird.physicsBody?.allowsRotation = false //禁止旋转
        bird.physicsBody?.categoryBitMask = birdCategory //设置小鸟物理体标识
        bird.physicsBody?.contactTestBitMask = floorCategory|pipeCategory //设置可以小鸟碰撞检测的物理体
        //contactTestBitMask是来设置可以与小鸟碰撞检测的物理体
        
        
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
    
    
    // MARK: 3.让内容动起来
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
        
        
        //循环检查场景的子节点，同时这个子节点的名字要为 pipe
        for pipeNode in self.children where pipeNode.name == "pipe" {
            
            //因为要用到水管的size,但是SKNode 没有size属性，所以要把它转成 SKSpriteNode 
            
            if let pipeSprite = pipeNode as?SKSpriteNode {
                //将水管左移1
                pipeSprite.position = CGPoint(x:pipeSprite.position.x - 1, y:pipeSprite.position.y)
                
                //检查水管是否完全超出了屏幕左侧，如果是则将它从场景里移除
                
                if pipeSprite.position.x < -pipeSprite.size.width*0.5 {
                    pipeSprite.removeFromParent()
                }
                
                
            }
            
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
    
    
    // MARK: 4.随机创建水管
    /*
     1,水管成对的出现,一个在上，一个在下，水管之间有一定的高度可以使小鸟通过
     2,上下水管之间的高度是随机的，但是有最大值和最小值
     3,一对水管出现了之后向左移动，移动出了屏幕左侧就要把它移除
     4,一对水管出现了之后，间隔一定的时间，再产生另外一对水管
     5,游戏初始化状态下停止重复创建水管，同时移除掉上一局残留的水管
     只有在游戏中才重复创建水管。
     游戏结束状态下，停止创建水光，如果还有水管，停止左移
     */
    
    
    //添加水管方法
    func addPipes(topSize:CGSize, buttomSize:CGSize) {
        //创建上部水管
        let topTexture = SKTexture(imageNamed:"topPipe") //利用上水管图片创建一个上水管纹理对象
        let topPipe = SKSpriteNode(texture:topTexture,size:topSize) //利用上水管纹理对象和传入的上水管大小参数创建一个上水管对象
        topPipe.name = "pipe" //给这个水管取名为 pipe
        topPipe.position = CGPoint(x:self.size.width + topPipe.size.width*0.5, y:self.size.height - topPipe.size.height*0.5)//设置上水管的垂直位置为顶部贴着屏幕顶部，水平位置在屏幕右侧之外
        
        
        //创建下水管，
        let bottomTexture = SKTexture(imageNamed:"bottomPipe") //利用上水管图片创建一个上水管纹理对象
        let bottomPipe = SKSpriteNode(texture:bottomTexture,size:buttomSize) //利用上水管纹理对象和传入的上水管大小参数创建一个上水管对象
        bottomPipe.name = "pipe" //给这个水管取名为 pipe
        bottomPipe.position = CGPoint(x:self.size.width + bottomPipe.size.width*0.5, y:self.floor1.size.height + bottomPipe.size.height*0.5)//设置上水管的垂直位置为顶部贴着屏幕顶部，水平位置在屏幕右侧之外
        
        //配置上水管物理体
        topPipe.physicsBody = SKPhysicsBody(texture:topTexture,size:topSize)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = pipeCategory
        
        //配置下水管物理体
        bottomPipe.physicsBody = SKPhysicsBody(texture:topTexture,size:topSize)
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.categoryBitMask = pipeCategory
        
        //将上下水管添加到场景里
        addChild(topPipe)
        addChild(bottomPipe)
        
    }
    
    
    //添加随机的水管到GameScene
    func createRandomPipes() {
        //先计算地板顶部道屏幕顶部的总可用高度
        let height = self.size.height - self.floor1.size.height
        
        //计算上下管道中间的空档的随机高度，最小空档高度为2.5倍的小鸟高度，最大高度为3.5倍的小鸟的高度
        let pipeGap = CGFloat(arc4random_uniform(UInt32(bird.size.height))) + bird.size.height*2.5
        
        //管道宽度在60
        let pipeWidth = CGFloat(60.0)
        
        //随机计算顶部pipe的随机高度，这个高度肯定要小于
        let topPipeHeight = CGFloat(arc4random_uniform(UInt32(height-pipeGap)))
        
        //总可用高度减去空档gap高度减去顶部水管topPipe高度剩下就是底部 bottomPipe高度
        let bottomPipeHeight = height - pipeGap - topPipeHeight
        
        //调用添加水管到场景方法
        addPipes(topSize: CGSize(width:pipeWidth,height:topPipeHeight), buttomSize: CGSize(width:pipeWidth,height:bottomPipeHeight))
        
        
    }
    
    //重复创建水管到并添加GameScene
    func startCreateRandomPipesAction() {
        //创建一个等待的action,等待时间的平均值为3.5s，变化范围为1s
        let waitAct = SKAction.wait(forDuration: 3.5, withRange: 1.0)
        
        //创建一个产生随机水管的action，这个action实际上就是调用一下 createRandomPipes() 方法
        
        let generatePipeAction = SKAction.run {
            self.createRandomPipes()
        }
        
        //让场景开始重复循环执行 “等待” -> "创建" -> "等待" -> "创建" 。。。。
        //并且给这个循环的动作设置一个叫做"createPipe"的key来标识它
        
        run(SKAction.repeatForever(SKAction.sequence([waitAct,generatePipeAction])), withKey: "createPipe")
        
    }
    
    
    //停止循环创建方法
    func stopCreateRandomPipesAction() {
        self.removeAction(forKey: "createPipe")
    }
    
    
    // MARK: 5物理世界
    /*
     小鸟没有受到重力作用
     点击屏幕小鸟不会向上飞
     碰到水管小鸟不会死掉
     */
    
    
    
    //移除场景中的所有水管
    func removeAllPipesNode() {
        for pipe in self.children where pipe.name == "pipe" {
            //循环检查场景的子节点，同时这个子节点的名字为pipe
                pipe.removeFromParent()//将水管这个节点从场景里移除掉
        }
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

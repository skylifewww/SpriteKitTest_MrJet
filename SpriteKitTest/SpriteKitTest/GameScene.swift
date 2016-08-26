//
//  GameScene.swift
//  SpriteKitTest
//
//  Created by Константин on 04.08.16.
//  Copyright © 2016 Константин. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Animations
    var animations = AnimationClass()
    
    //Variables
    var sound = true
    var moveElectricGateY = SKAction()
    
    //Texture
    var bgTexture: SKTexture!
    var flyHeroTex: SKTexture!
    var runHeroTex: SKTexture!
    var coinTexture: SKTexture!
    var redCoinTexture: SKTexture!
    var coinHeroTex: SKTexture!
    var redCoinHeroTex: SKTexture!
    var electricGateTex: SKTexture!
    var deadHeroTex: SKTexture!
    
    //Emitters Node
    var heroEmitter1 = SKEmitterNode()
    
    //Sprite Nodes
    var bg = SKSpriteNode()
    var ground = SKSpriteNode()
    var sky = SKSpriteNode()
    var hero = SKSpriteNode()
    var coin = SKSpriteNode()
    var redCoin = SKSpriteNode()
    var electricGate = SKSpriteNode()
  
    
    //Sprite Objects
    var bgObject = SKNode()
    var groundObject = SKNode()
    var movingObject = SKNode()
    var heroObject = SKNode()
    var heroEmitterObject = SKNode()
    var coinObject = SKNode()
    var redCoinObject = SKNode()

    
    //Bit masks
    var heroGroup: UInt32 = 0x1 << 1
    var groundGroup: UInt32 = 0x1 << 2
    var coinGroup: UInt32 = 0x1 << 3
    var redCoinGroup: UInt32 = 0x1 << 4
    var objectGroup: UInt32 = 0x1 << 5
    
    //Textures Array for animateWithTextures
    var heroFlyTexturesArray = [SKTexture]()
    var heroRunTexturesArray = [SKTexture]()
    var coinTexturesArray = [SKTexture]()
    var electricGateTexturesArray = [SKTexture]()
    var heroDeathTexturesArray = [SKTexture]()
    
    //Timers
    var timerAddCoin = Timer()
    var timerAddRedCoin = Timer()
    var timerAddElectricGate = Timer()
    
    //Sounds
    var pickCoinPreload = SKAction()
    var electricGateCreatePreload = SKAction()
    var electricGateDeathPreload = SKAction()

    override func didMove(to view: SKView) {
        //Background texture
        bgTexture = SKTexture(imageNamed: "bg01.png")
        
        //Hero texture
        flyHeroTex = SKTexture(imageNamed: "Fly0.png")
        runHeroTex = SKTexture(imageNamed: "Run0.png")
        deadHeroTex = SKTexture(imageNamed: "Dead0.png")
        
        //Coin texture
        coinTexture = SKTexture(imageNamed: "coin.jpg")
        redCoinTexture = SKTexture(imageNamed: "coin.jpg")
        coinHeroTex = SKTexture(imageNamed: "Coin0.png")
        redCoinHeroTex = SKTexture(imageNamed: "Coin0.png")
        
        //ElectricGate texture
        electricGateTex = SKTexture(imageNamed: "ElectricGate01.png")
        
        
        //Emitters
        heroEmitter1 = SKEmitterNode(fileNamed: "engine.sks")!
        
        self.physicsWorld.contactDelegate = self
        
        createObjects()
        createGame()
        
        pickCoinPreload = SKAction.playSoundFileNamed("pickCoin.mp3", waitForCompletion: false)
        electricGateCreatePreload = SKAction.playSoundFileNamed("electricCreate.wav", waitForCompletion: false)
        electricGateDeathPreload = SKAction.playSoundFileNamed("electricDead.mp3", waitForCompletion: false)

        
    }
    
    func createObjects() {
        self.addChild(bgObject)
        self.addChild(groundObject)
        self.addChild(movingObject)
        self.addChild(heroObject)
        self.addChild(heroEmitterObject)
        self.addChild(coinObject)
        self.addChild(redCoinObject)
    }
    
    func createGame() {
        createBg()
        createGround()
        createSky()
       
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) { 
            self.createHero()
            self.createHeroEmitter()
            self.timerFunc()
            self.addElectricGate()
    
        }
    }
    
    func createBg() {
        bgTexture = SKTexture(imageNamed: "bg01.png")
        
        let moveBg = SKAction.moveBy(x: -bgTexture.size().width, y: 0, duration: 3)
        let replaceBg = SKAction.moveBy(x: bgTexture.size().width, y: 0, duration: 0)
        let moveBgForever = SKAction.repeatForever(SKAction.sequence([moveBg, replaceBg]))
        
        for i in 0..<3 {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: size.width/4 + bgTexture.size().width * CGFloat(i), y: size.height/2.0)
            bg.size.height = self.frame.height
            bg.run(moveBgForever)
            bg.zPosition = -1
            
            bgObject.addChild(bg)
        }
    }
    
    func createGround() {
        ground = SKSpriteNode()
        ground.position = CGPoint.zero
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: self.frame.height/4 + self.frame.height/8))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundGroup
        ground.zPosition = 1
        
        groundObject.addChild(ground)
    }
    
    func createSky() {
        sky = SKSpriteNode()
        sky.position = CGPoint(x: 0, y: self.frame.maxX)
        sky.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width + 100, height: self.frame.size.height - 100))
        sky.physicsBody?.isDynamic = false
        sky.zPosition = 1
        
        movingObject.addChild(sky)
    }
    
    func addHero(heroNode: SKSpriteNode, atPosition position: CGPoint) {
        hero = SKSpriteNode(texture: flyHeroTex)
        
        //Anim hero
        heroFlyTexturesArray = [SKTexture(imageNamed: "Fly0.png"), SKTexture(imageNamed: "Fly1.png"), SKTexture(imageNamed: "Fly2.png"), SKTexture(imageNamed: "Fly3.png"), SKTexture(imageNamed: "Fly4.png")]
        let heroFlyAnimation = SKAction.animate(with: heroFlyTexturesArray, timePerFrame: 0.1)
        let flyHero = SKAction.repeatForever(heroFlyAnimation)
        hero.run(flyHero)
        
        hero.position = position
        hero.size.height = 84
        hero.size.width = 120
        
        hero.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: hero.size.width - 40, height: hero.size.height - 30))
        
        hero.physicsBody?.categoryBitMask = heroGroup
        hero.physicsBody?.contactTestBitMask = groundGroup | coinGroup | redCoinGroup | objectGroup
        hero.physicsBody?.collisionBitMask = groundGroup
        
        hero.physicsBody?.isDynamic = true
        hero.physicsBody?.allowsRotation = false
        hero.zPosition = 1
        
        heroObject.addChild(hero)
    }
    
    func createHero() {
        addHero(heroNode: hero, atPosition: CGPoint(x: self.size.width/4, y: 0 + flyHeroTex.size().height + 400))
    }
    
    func createHeroEmitter() {
        heroEmitter1 = SKEmitterNode(fileNamed: "engine.sks")!
        heroEmitterObject.zPosition = 1
        heroEmitterObject.addChild(heroEmitter1)
    }
    
    func addCoin() {
        coin = SKSpriteNode(texture: coinTexture)
        
        coinTexturesArray = [SKTexture(imageNamed: "Coin0.png"), SKTexture(imageNamed: "Coin1.png"), SKTexture(imageNamed: "Coin2.png"), SKTexture(imageNamed: "Coin3.png")]
        
        let coinAnimation = SKAction.animate(with: coinTexturesArray, timePerFrame: 0.1)
        let coinHero = SKAction.repeatForever(coinAnimation)
        coin.run(coinHero)
        
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        coin.size.width = 40
        coin.size.height = 40
        coin.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: coin.size.width - 20, height: coin.size.height - 20))
        coin.physicsBody?.restitution = 0
        coin.position = CGPoint(x: self.size.width + 50, y: 0 + coinTexture.size().height + 90 + pipeOffset)
        
        let moveCoin = SKAction.moveBy(x: -self.frame.size.width * 2, y: 0, duration: 5)
        let removeAction = SKAction.removeFromParent()
        let coinMoveBgForever = SKAction.repeatForever(SKAction.sequence([moveCoin, removeAction]))
        coin.run(coinMoveBgForever)
        
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = coinGroup
        coin.zPosition = 1
        coinObject.addChild(coin)
    }
    
    func redCoinAdd() {
        redCoin = SKSpriteNode(texture: redCoinTexture)
        
        coinTexturesArray = [SKTexture(imageNamed: "Coin0.png"), SKTexture(imageNamed: "Coin1.png"), SKTexture(imageNamed: "Coin2.png"), SKTexture(imageNamed: "Coin3.png")]
        
        let redCoinAnimation = SKAction.animate(with: coinTexturesArray, timePerFrame: 0.1)
        let redCoinHero = SKAction.repeatForever(redCoinAnimation)
        redCoin.run(redCoinHero)
        
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        redCoin.size.width = 40
        redCoin.size.height = 40
        redCoin.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: redCoin.size.width - 10, height: redCoin.size.height - 10))
        redCoin.physicsBody?.restitution = 0
        redCoin.position = CGPoint(x: self.size.width + 50, y: 0 + coinTexture.size().height + 90 + pipeOffset)
        
        let moveCoin = SKAction.moveBy(x: -self.frame.size.width * 2, y: 0, duration: 5)
        let removeAction = SKAction.removeFromParent()
        let coinMoveBgForever = SKAction.repeatForever(SKAction.sequence([moveCoin, removeAction]))
        redCoin.run(coinMoveBgForever)
        animations.scaleZdirection(sprite: redCoin)
        animations.redColorAnimation(sprite: redCoin, animDuration: 0.5)
        redCoin.setScale(1.3)
        redCoin.physicsBody?.isDynamic = false
        redCoin.physicsBody?.categoryBitMask = redCoinGroup
        redCoin.zPosition = 1
        redCoinObject.addChild(redCoin)
    }
    
    func addElectricGate() {
        if sound == true {
            run(electricGateCreatePreload)
            
        }
        electricGate = SKSpriteNode(texture: electricGateTex)
        electricGateTexturesArray = [SKTexture(imageNamed: "ElectricGate01.png"), SKTexture(imageNamed: "ElectricGate02.png"), SKTexture(imageNamed: "ElectricGate03.png"), SKTexture(imageNamed: "ElectricGate04.png")]
        
        let electricGateAnimation = SKAction.animate(with: electricGateTexturesArray, timePerFrame: 0.1)
        let electricGateAnimationForever = SKAction.repeatForever(electricGateAnimation)
        electricGate.run(electricGateAnimationForever)
    
        let randomPosition = arc4random() % 2
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 5)
        let pipeOffset = self.frame.size.height / 4 + 30 - CGFloat(movementAmount)
        
        if randomPosition == 0 {
            electricGate.position = CGPoint(x: self.size.width + 50, y: electricGateTex.size().height/2 + 90 + pipeOffset)
            
            
        } else {
            electricGate.position = CGPoint(x: self.size.width + 50, y: self.frame.size.height - electricGateTex.size().height/2 - 90 - pipeOffset)
            
        }
        electricGate.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: electricGate.size.width - 40, height: electricGate.size.height - 20))
        
        //Rotate
        electricGate.run(SKAction.repeatForever(SKAction.sequence([SKAction.run({
        self.electricGate.run(SKAction.rotate(byAngle: CGFloat(M_PI * 2), duration: 0.5))
        }), SKAction.wait(forDuration: 20.0)])))

        //Move
        let moveAction = SKAction.moveBy(x: -self.frame.width - 300, y: 0, duration: 6)
        electricGate.run(moveAction)
        
        //Scale
        var scaleValue: CGFloat = 0.3
        
        
        let scaleRandom = arc4random() % UInt32(5)
        if scaleRandom == 1 { scaleValue = 0.9 }
        else if scaleRandom == 2 { scaleValue = 0.6 }
        else if scaleRandom == 3 { scaleValue = 0.8 }
        else if scaleRandom == 4 { scaleValue = 0.7 }
        else if scaleRandom == 0 { scaleValue = 1.0 }
        
        electricGate.setScale(scaleValue)
        
        let movementRandom = arc4random() % 9
        if movementRandom == 0 {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2 + 220, duration: 4)
        } else if movementRandom == 1 {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2 - 220, duration: 5)
        } else if movementRandom == 2 {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2 - 150, duration: 4)
        } else if movementRandom == 3 {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2 + 150, duration: 5)
        } else if movementRandom == 4 {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2 + 50, duration: 4)
        } else if movementRandom == 5 {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2 - 50, duration: 5)
        } else {
            moveElectricGateY = SKAction.moveTo(y: self.frame.height / 2, duration: 4)
        }
        
        electricGate.run(moveElectricGateY)

        
        electricGate.physicsBody?.restitution = 0
        electricGate.physicsBody?.isDynamic = false
        electricGate.physicsBody?.categoryBitMask = objectGroup
        electricGate.zPosition = 1
        
        
        movingObject.addChild(electricGate)
        
    }
    
    func timerFunc() {
        timerAddCoin.invalidate()
        timerAddRedCoin.invalidate()
        timerAddElectricGate.invalidate()
        
        timerAddCoin = Timer.scheduledTimer(timeInterval: 2.64, target: self, selector: #selector(GameScene.addCoin), userInfo: nil, repeats: true)
        timerAddRedCoin = Timer.scheduledTimer(timeInterval: 8.246, target: self, selector: #selector(GameScene.redCoinAdd), userInfo: nil, repeats: true)
        timerAddElectricGate = Timer.scheduledTimer(timeInterval: 5.234, target: self, selector: #selector(GameScene.addElectricGate), userInfo: nil, repeats: true)
    }
    
    func stopGameObject() {
        coinObject.speed = 0
        redCoinObject.speed = 0
        heroEmitterObject.speed = 0
        movingObject.speed = 0
    }
    
    override func didFinishUpdate() {
        heroEmitter1.position = hero.position - CGPoint(x: 33, y: 30)
    }
}

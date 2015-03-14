//
//  GameScene.swift
//  Game
//
//  Created by Marvin Muuß on 07.01.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import SpriteKit


struct PhysicsCategory {
  static let None      : UInt32 = 0
  static let All       : UInt32 = UInt32.max
  static let Blocks   : UInt32 = 0b1       // 1
  static let Lava : UInt32 = 0b10
  static let Player: UInt32 = 0b11      // 2
  static let Monster: UInt32 = 0b100
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  let player = SKSpriteNode(imageNamed: "player")
  var tileMap = JSTileMap(named: "level1.tmx")
  
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    /*    let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel) */
      
      backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.95, alpha: 1.0)
      
      self.anchorPoint = CGPoint(x: 0, y: 0)
      self.position = CGPoint(x: 0, y: 0)
      
      let rect = tileMap.calculateAccumulatedFrame()
      tileMap.position = CGPoint(x: 0, y: 0)
      
      
      // 3
      player.position = CGPoint(x: 100, y: 50)
      player.zPosition = 15
        
      // 4
      
      tileMap.addChild(player)
      addChild(tileMap)
      
      physicsWorld.gravity = CGVectorMake(0, -1)
      physicsWorld.contactDelegate = self

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
      /*  for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        } */
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
}
}

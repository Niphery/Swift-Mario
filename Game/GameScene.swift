//
//  GameScene.swift
//  Game
//
//  Created by Marvin Muuß on 07.01.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import SpriteKit
//import "JSTileMap.h"


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
      
      let blue = SKColor(CIColor: CIColor(red: 180, green: 200, blue: 230))
      backgroundColor = SKColor.lightGrayColor()
      // 3
      player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
      
   //   self.map = tileMap
      
      // 4
      addChild(player)
      
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

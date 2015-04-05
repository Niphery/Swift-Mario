//
//  Player.swift
//  Game
//
//  Created by Marvin Muuß on 05.04.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import Foundation
import SpriteKit

class Player:SKSpriteNode {
  
  var velocity: CGPoint
  var collisionBoundingBox: CGRect
  
  override init (){
    self.velocity = CGPointMake(0.0, 0.0)
    let texture = SKTexture(imageNamed: "player")
    collisionBoundingBox = CGRect(x: 0, y: 0, width: 0, height: 0)
    super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    collisionBoundingBox = CGRectInset(self.frame,2,0)
    
  }
  
  

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func update (delta: NSTimeInterval){
    var gravity = CGPointMake(0.0, -450.0)
//    var gravityStep = CGPointMultiplyScalar(gravity, scalar: CGFloat(delta))
    var gravityStep = gravity * CGFloat(delta)
    self.velocity = self.velocity + gravityStep
//    var velocityStep = CGPointMultiplyScalar(self.velocity, scalar: CGFloat(delta))
    var velocityStep = self.velocity * CGFloat(delta)
    
    self.position = self.position + velocityStep
//    self.velocity = CGPointAdd
  }
  
  func CGPointMultiplyScalar(point: CGPoint, scalar: CGFloat) -> CGPoint{
    return CGPointMake(point.x * scalar, point.y * scalar)
  }
  

}
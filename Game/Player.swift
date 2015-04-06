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
  var desiredPosition: CGPoint
  var onGround: Bool
  
  override init (){
    self.desiredPosition = CGPointMake(0.0,0.0)
    self.velocity = CGPointMake(0.0, 0.0)
    self.onGround = false
    let texture = SKTexture(imageNamed: "player")
    super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    self.desiredPosition = self.position
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func update (delta: NSTimeInterval){
    var gravity = CGPointMake(0.0, -450.0)
    var gravityStep = gravity * CGFloat(delta)
    self.velocity = self.velocity + gravityStep
    var velocityStep = self.velocity * CGFloat(delta)
    
//    self.position = self.position + velocityStep
    self.desiredPosition = self.position + velocityStep
  }
  
  func CGPointMultiplyScalar(point: CGPoint, scalar: CGFloat) -> CGPoint{
    return CGPointMake(point.x * scalar, point.y * scalar)
  }
  
  func collisionBoundingBox() -> CGRect {
    var boundingBox = CGRectInset(self.frame, 2, 0)
    var diff = self.desiredPosition - self.position
    
    return CGRectOffset(boundingBox, diff.x, diff.y);
  }
  

}
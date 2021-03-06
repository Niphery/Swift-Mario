//
//  Mario.swift
//  Game
//
//  Created by Marvin Muuß on 05.04.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import Foundation
import SpriteKit

class Mario:SKSpriteNode {
  
  var velocity: CGPoint
  var desiredPosition: CGPoint
  var onGround: Bool
  var mightJump: Bool
  var moveForward: Bool
  
  override init (){
    self.desiredPosition = CGPointMake(0.0,0.0)
    self.velocity = CGPointMake(0.0, 0.0)
    self.onGround = false
    let texture = SKTexture(imageNamed: "mario")
    mightJump = false
    moveForward = false
    super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    self.desiredPosition = self.position
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func update (delta: NSTimeInterval){
    var gravity = CGPointMake(0.0, -450.0)
    var gravityStep = gravity * CGFloat(delta)
    var forwardMove = CGPointMake(800.0, 0.0)
    var forwardStep = forwardMove * CGFloat(delta)
    
    self.velocity = self.velocity + gravityStep
    
    self.velocity = CGPointMake(self.velocity.x * 0.9, self.velocity.y)
    
    var jumpHeight = CGPointMake(0, 310)
    var restrictJump:CGFloat = 150
    
    if (self.mightJump && self.onGround) {
      self.velocity = self.velocity + jumpHeight
    } else if (!self.mightJump && self.velocity.y > restrictJump) {
      self.velocity = CGPointMake(self.velocity.x, restrictJump)
    }
    
    if (self.moveForward){
      self.velocity = self.velocity + forwardStep
    }
    
    var minMovement = CGPointMake(0.0,-450)
    var maxMovement = CGPointMake(120,250)
    
    self.velocity = CGPointMake(clamp(self.velocity.x, min: minMovement.x, max: maxMovement.x), clamp(self.velocity.y, min: minMovement.y, max: maxMovement.y))
    
    var velocityStep = self.velocity * CGFloat(delta)    
    
    self.desiredPosition = self.position + velocityStep
    println(self.position)
  }
  
  func collisionBoundingBox() -> CGRect {
    var boundingBox = CGRectInset(self.frame, 2, 0)
    var diff = self.desiredPosition - self.position
    
    return CGRectOffset(boundingBox, diff.x, diff.y);
  }
  
  /*
  * Stellt sicher, dass value in der Range von min und max liegt und beschraenkt es ggf.
  */
  func clamp(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    if (value < min){
      return min
    } else if (value > max){
      return max
    } else {
      return value
    }
  }
  

}
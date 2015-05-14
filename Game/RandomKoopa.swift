//
//  Mario.swift
//  Game
//
//  Created by Marvin Muuß on 05.04.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import Foundation

class MagicKoopa : Monster {
  
  init() {
    let texture = SKTexture(imageNamed: "Koopa")
    super.init(texture: texture)
    self.mightJump = true
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func update(delta: NSTimeInterval){
    var gravity = CGPointMake(0.0, -450.0)
    var gravityStep = gravity * CGFloat(delta)
    var v:CGFloat = 400.0
    if (velocity.x < 0){
      v = -400.0
    } else {
      v = 400.0
    }
    var forwardMove = CGPointMake(v, 0.0)
    var forwardStep = forwardMove * CGFloat(delta)
    
    self.velocity = self.velocity + gravityStep
    
    self.velocity = CGPointMake(self.velocity.x * 0.9, self.velocity.y)
    
    var jumpHeight = CGPointMake(0, 170)
    var restrictJump:CGFloat = 150
    
    var r = RandomFloat()*10
    
    if(r < 0.5){
      self.mightJump = true
    } else {
      self.mightJump = false
    }
    
    
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
    
    super.update(delta)
  }
  
}
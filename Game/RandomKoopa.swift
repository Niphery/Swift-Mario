//
//  Mario.swift
//  Game
//
//  Created by Marvin Muuß on 05.04.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import Foundation

class RandomKoopa : Monster {
  
  init() {
    let texture = SKTexture(imageNamed: "Koopa")
    super.init(texture: texture)
    self.mightJump = true
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func update(_ delta: TimeInterval){
    let gravity = CGPoint(x: 0.0, y: -450.0)
    let gravityStep = gravity * CGFloat(delta)
    var v:CGFloat = 400.0
    if (velocity.x < 0){
      v = -400.0
    } else {
      v = 400.0
    }
    let forwardMove = CGPoint(x: v, y: 0.0)
    let forwardStep = forwardMove * CGFloat(delta)
    
    self.velocity = self.velocity + gravityStep
    
    self.velocity = CGPoint(x: self.velocity.x * 0.9, y: self.velocity.y)
    
    let jumpHeight = CGPoint(x: 0, y: 170)
    let restrictJump:CGFloat = 150
    
    let r = RandomFloat()*10
    
    if(r < 0.5){
      self.mightJump = true
    } else {
      self.mightJump = false
    }
    
    
    if (self.mightJump && self.onGround) {
      self.velocity = self.velocity + jumpHeight
    } else if (!self.mightJump && self.velocity.y > restrictJump) {
      self.velocity = CGPoint(x: self.velocity.x, y: restrictJump)
    }
    
    if (self.moveForward){
      self.velocity = self.velocity + forwardStep
    }
    
    let minMovement = CGPoint(x: 0.0,y: -450)
    let maxMovement = CGPoint(x: 120,y: 250)
    
    self.velocity = CGPoint(x: clamp(self.velocity.x, min: minMovement.x, max: maxMovement.x), y: clamp(self.velocity.y, min: minMovement.y, max: maxMovement.y))
    
    let velocityStep = self.velocity * CGFloat(delta)
    
    self.desiredPosition = self.position + velocityStep
    
    super.update(delta)
  }
  
}

//
//  Mario.swift
//  Game
//
//  Created by Marvin Muuß on 05.04.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import Foundation
import SpriteKit

class Mario: SKSpriteNode {
  
  var velocity = CGPoint(x: 0.0, y: 0.0)
  var desiredPosition = CGPoint(x: 0.0,y: 0.0)
  var onGround = false
  var mightJump = false
  var moveForward = false
  
  init() {
    let texture = SKTexture(imageNamed: "mario")
    super.init(texture: texture, color: UIColor.clear, size: texture.size())
    self.desiredPosition = self.position
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func update (_ delta: TimeInterval){
    let gravity = CGPoint(x: 0.0, y: -450.0)
    let gravityStep = gravity * CGFloat(delta)
    let forwardMove = CGPoint(x: 800.0, y: 0.0)
    let forwardStep = forwardMove * CGFloat(delta)
    
    self.velocity = self.velocity + gravityStep
    
    self.velocity = CGPoint(x: self.velocity.x * 0.9, y: self.velocity.y)
    
    let jumpHeight = CGPoint(x: 0, y: 310)
    let restrictJump:CGFloat = 150
    
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
    print(self.position)
  }
  
  func collisionBoundingBox() -> CGRect {
    let boundingBox = self.frame.insetBy(dx: 2, dy: 0)
    let diff = self.desiredPosition - self.position
    
    return boundingBox.offsetBy(dx: diff.x, dy: diff.y);
  }
  
  /*
  * Stellt sicher, dass value in der Range von min und max liegt und beschraenkt es ggf.
  */
  func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    if (value < min){
      return min
    } else if (value > max){
      return max
    } else {
      return value
    }
  }
  

}

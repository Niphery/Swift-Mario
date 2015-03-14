//
//  Mario.swift
//  Game
//
//  Created by Marvin Muuß on 13.03.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import Foundation
import SpriteKit

class Mario: SKSpriteNode {
  
    var x,y,width,height,velx,vely: Int

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  init(x: Int, y:Int, width: Int, height:Int) {
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    velx = 0
    vely = 0
    super.init()
  }
  

  
  
  
    
}
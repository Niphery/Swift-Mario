//
//  ReplayScene.swift
//  Game
//
//  Created by Marvin Muuß on 08.04.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import Foundation
import SpriteKit

protocol ReplaySceneDelegate{
  func replaySceneDidFinish(myScene: ReplayScene, command: String)
}

class ReplayScene: SKScene {
  
  var thisDelegate: ReplaySceneDelegate?
  
  override func didMoveToView(view: SKView){
    let leftMargin = view.bounds.width / 2
    let topMargin = view.bounds.height / 4
    
    let replayLabel = SKLabelNode(fontNamed: "Arial")
    replayLabel.text = "Replay?"
    replayLabel.fontSize = 42
    replayLabel.position = CGPoint(x: leftMargin, y: view.bounds.height - topMargin)
    self.addChild(replayLabel)
    
    let playAgainButton = UIButton(frame: CGRectMake(leftMargin / 2, topMargin + 30,100,50))
    playAgainButton.setTitle("Yes", forState: UIControlState.Normal)
    playAgainButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
    playAgainButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchDown)
    
    self.view?.addSubview(playAgainButton)
  }
  
  func buttonAction(sender: UIButton!){
    if (sender!.currentTitle == "Yes"){
      self.thisDelegate!.replaySceneDidFinish(self,command:"Restart")
    }
  }
  
}

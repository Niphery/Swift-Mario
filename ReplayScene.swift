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
	func replaySceneDidFinish(_ myScene: ReplayScene, command: String)
}

class ReplayScene: SKScene {

	var thisDelegate: ReplaySceneDelegate?

	override func didMove(to view: SKView){
		let leftMargin = view.bounds.width / 2
		let topMargin = view.bounds.height / 4

		let replayLabel = SKLabelNode(fontNamed: "Arial")
		replayLabel.text = "Replay?"
		replayLabel.fontSize = 42
		replayLabel.position = CGPoint(x: leftMargin, y: view.bounds.height - topMargin)
		addChild(replayLabel)

		let playAgainButton = UIButton(frame: CGRect(x: leftMargin / 2, y: topMargin + 30,width: 100,height: 50))
		playAgainButton.setTitle("Yes", for: UIControlState())
		playAgainButton.setTitleColor(UIColor.green, for: UIControlState())
		playAgainButton.addTarget(self, action: #selector(ReplayScene.buttonAction(_:)), for: UIControlEvents.touchDown)

		view.addSubview(playAgainButton)
	}

	func buttonAction(_ sender: UIButton!){
		if (sender!.currentTitle == "Yes"){
			thisDelegate!.replaySceneDidFinish(self,command:"Restart")
		}
	}

}

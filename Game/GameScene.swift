//
//  GameScene.swift
//  Game
//
//  Created by Marvin Muuß on 07.01.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import Foundation
import SpriteKit

struct CollisionCategoryBitmask {
	static let pMarioCategory: UInt32 = 0x00
	static let pEnemyCategory: UInt32 = 0x01

}

class GameScene: SKScene, SKPhysicsContactDelegate, ReplaySceneDelegate {

	let player = Mario()
	let koopa = Koopa()
	let jumpingKoopa = JumpingKoopa()
	let randomKoopa = RandomKoopa()
	let randomKoopa2 = RandomKoopa()
	let randomKoopa3 = RandomKoopa()
	var tileMap = JSTileMap(named: "level1.tmx")
	var spikes = TMXLayer()
	var walls = TMXLayer()
	var previousUpdateTime: CFTimeInterval = 0.0
	var gameOver = false
	var replayView: SKView?
	let level2: SKView? = nil

	func replaySceneDidFinish(_ myScene: ReplayScene, command: String){
		myScene.view?.removeFromSuperview()
		if (command == "Restart"){
			let sceneNew = GameScene(size: self.view!.bounds.size)
			self.view?.presentScene(sceneNew)
		}
	}

	override func didMove(to view: SKView) {

		self.replayView = SKView(frame: CGRect(x: self.frame.size.width / 4, y: self.frame.size.height / 4,
		                                       width: self.frame.size.width / 2, height: self.frame.size.height / 2))
		let replayScene = ReplayScene(size: CGSize(width: self.frame.size.width / 2, height: self.frame.size.height / 2))
		replayScene.thisDelegate = self

		self.replayView!.presentScene(replayScene)

		SKTAudio.sharedInstance().playBackgroundMusic("Mario Bros Theme.mp3")

		self.isUserInteractionEnabled = true
		view.isMultipleTouchEnabled = true

		backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.95, alpha: 1.0)

		self.anchorPoint = CGPoint(x: 0, y: 0)
		self.position = CGPoint(x: 0, y: 0)

		let rect = tileMap?.calculateAccumulatedFrame() // TODO: never used
		tileMap?.position = CGPoint(x: 0, y: 0)

		player.position = CGPoint(x: 100, y: 50)
		player.zPosition = 15
		player.physicsBody = SKPhysicsBody(rectangleOf: player.collisionBoundingBox().size)
		player.physicsBody?.isDynamic = true
		player.physicsBody?.affectedByGravity = false
		player.physicsBody?.categoryBitMask = CollisionCategoryBitmask.pMarioCategory
		player.physicsBody?.collisionBitMask = CollisionCategoryBitmask.pEnemyCategory
		player.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.pEnemyCategory

		tileMap?.addChild(player)
		spikes = (tileMap?.layerNamed("spikes"))!
		walls = (tileMap?.layerNamed("walls"))!
		addChild(tileMap!)

		addEnemies()
		loadGameControls()

		physicsWorld.gravity = CGVector(dx: 0, dy: -1)
		physicsWorld.contactDelegate = self

	}

	func addEnemies(){
		koopa.position = CGPoint(x:1186, y:50)
		setKoopaSettings(koopa)

		jumpingKoopa.position = CGPoint(x:512, y:50)
		setKoopaSettings(jumpingKoopa)

		randomKoopa.position = CGPoint(x:1981, y:50)
		setKoopaSettings(randomKoopa)

		randomKoopa2.position = CGPoint(x: 2306,y: 50)
		setKoopaSettings(randomKoopa2)

		randomKoopa3.position = CGPoint(x: 2700,y: 50)
		setKoopaSettings(randomKoopa3)

		tileMap?.addChild(koopa)
		tileMap?.addChild(jumpingKoopa)
		tileMap?.addChild(randomKoopa)
		tileMap?.addChild(randomKoopa2)
		tileMap?.addChild(randomKoopa3)
	}

	func setKoopaSettings(_ koopa: Monster){
		koopa.zPosition = 15
		koopa.physicsBody = SKPhysicsBody(rectangleOf: koopa.collisionBoundingBox().size)
		koopa.physicsBody?.isDynamic = true
		koopa.physicsBody?.affectedByGravity = false
		koopa.physicsBody?.categoryBitMask = CollisionCategoryBitmask.pEnemyCategory
		koopa.physicsBody?.collisionBitMask = CollisionCategoryBitmask.pMarioCategory
		koopa.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.pMarioCategory
		koopa.setTileMap(map: tileMap!)
	}

	func didBegin(_ contact: SKPhysicsContact) {
		gameOver(false)
	}

	/*
	* Checkt, ob gesprungen oder sich bewegt werden soll
	*/
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		/* Called when a touch begins */
		for touch in touches {
			let touchLocation = touch.location(in: self)
			for node in nodes(at: touchLocation) {
				guard let name = node.name else { continue }
				switch name {
				case "rightArrowButton":
					player.moveForward = true
				case "leftArrowButton":
					player.moveBackward = true
				case "upArrowButton":
					player.mightJump = true
				default:
					break
				}
			}
		}
	}

	/*
	* Wird der Finger waehrend er Beruehrung verschoben, muss ueberprueft werden, ob sich die Position ueber die Bildschirmmitte schiebt
	*/
	// TODO: Fix exiting from button while moving
//	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//		for touch: AnyObject in touches {
//			let halfWidth:CGFloat = self.size.width / 2.0
//			let touchLocation:CGPoint = touch.location(in: self)
//
//			let previousTouchLocation = touch.previousLocation(in: self)
//
//			if (touchLocation.x > halfWidth && previousTouchLocation.x <= halfWidth){
//				self.player.moveForward = false
//				self.player.mightJump = true
//			} else if (previousTouchLocation.x > halfWidth && touchLocation.x <= halfWidth){
//				self.player.moveForward = true
//				self.player.mightJump = false
//			}
//		}
//	}

	/*
	* Beendet die Bewegung
	*/
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch: AnyObject in touches {
			let touchLocation = touch.location(in: self)
			for node in nodes(at: touchLocation) {
				guard let name = node.name else { continue }
				switch name {
				case "rightArrowButton":
					player.moveForward = false
				case "leftArrowButton":
					player.moveBackward = false
				case "upArrowButton":
					player.mightJump = false
				default:
					break
				}
			}
		}
	}

	/*
	* Wird bei jedem Frame aufgerufen und aktualisiert die Positon des Spielers
	* und checkt ob es collisionen gibt
	*/
	override func update(_ currentTime: TimeInterval) {
		/* Called before each frame is rendered */

		if (gameOver){
			return
		}

		var delta = currentTime - previousUpdateTime

		if (delta > 0.02){
			delta = 0.02
		}
		previousUpdateTime = currentTime

		self.setViewpointCenter(self.player.position)
		player.update(delta)
		koopa.update(delta)
		jumpingKoopa.update(delta)
		randomKoopa.update(delta)
		randomKoopa2.update(delta)
		randomKoopa3.update(delta)

		self.checkForAndResolveCollisionsForPlayer(self.player, forLayer: walls)
		self.handleSpikeCollision(self.player)
		self.checkForWin()

	}

	/*
	* aktualisiert die View und schiebt sie evtl weiter
	*/
	func setViewpointCenter(_ position: CGPoint){
		var x = max(position.x, self.size.width / 2)
		var y = max(position.y, self.size.height / 2)

		x = min(x,((self.tileMap?.mapSize.width)! * (self.tileMap?.tileSize.width)!) - self.size.width / 2)
		y = min(y,((self.tileMap?.mapSize.height)! * (self.tileMap?.tileSize.height)!) - self.size.height / 2)

		let actualPosition = CGPoint(x: x,y: y)
		let centerView = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
		let view = centerView - actualPosition

		self.tileMap?.position = view
	}


	/*
	* Liefert den Urpsrungspixel eines Tiles zurueck.
	* Umrechnung weil TMXTiles oben links statt unten links starten
	*/
	func tileRectFromTileCoords(_ tileCoords: CGPoint) -> CGRect{
		let levelHeightInPixels = (tileMap?.mapSize.height)! * (tileMap?.tileSize.height)!
		var i = levelHeightInPixels - ((tileCoords.y + 1 ) * (tileMap?.tileSize.height)!) // TODO: never used
		let origin = CGPoint(x: tileCoords.x * (tileMap?.tileSize.width)!, y: levelHeightInPixels - ((tileCoords.y + 1 ) * (tileMap?.tileSize.height)!))
		return CGRect(x: origin.x, y: origin.y, width: tileMap!.tileSize.width, height: tileMap!.tileSize.height)
	}

	/*
	* Liefer GID des Tiles abhaengig der Kooridnate zurueck.
	* Die GID ist eine Nummer, die ein Bild von der Menge der Tiles darstellt
	*/
	func tileGIDAtTileCoord(_ coord: CGPoint, forLayer layer: TMXLayer!) -> Int {
		let layerInfo:TMXLayerInfo = layer.layerInfo
		let i = layerInfo.tileGid(atCoord: coord)
		return i
	}

	/*
	* Ueberprueft die Kollisionen zwischen dem Spieler und einem Layer
	* Bevorzugt mit walls auf denen sich der Spieler schließlich bewegt.
	* Dabei wird in der Reihenfolge unten, oben, links, rechts und schließlich diagonal ueberprueft
	*/
	func checkForAndResolveCollisionsForPlayer(_ player: Mario!, forLayer layer: TMXLayer!){
		let indices = [7, 1, 3, 5, 0, 2, 6, 8]
		player.onGround = false
		for item in indices {
			let tileIndex:NSInteger = item
			let playerRect:CGRect = player.collisionBoundingBox()
			let playerCoord:CGPoint = layer.coord(for: player.desiredPosition)

			//falls der Spieler aus der Map gefallen ist
			if (playerCoord.y >= (tileMap?.mapSize.height)! - 1){
				self.gameOver(false)
				return
			}

			let tileColumn:NSInteger = tileIndex % 3
			let tileRow:NSInteger = tileIndex / 3

			let x = playerCoord.x + CGFloat(tileColumn - 1)
			let y = playerCoord.y + CGFloat(tileRow - 1)
			let tileCoord = CGPoint(x: x, y: y)

			let gid:NSInteger = self.tileGIDAtTileCoord(tileCoord, forLayer: layer)

			if (gid != 0){
				let tileRect = self.tileRectFromTileCoords(tileCoord)

				if (playerRect.intersects(tileRect)) {
					let intersection: CGRect = playerRect.intersection(tileRect);
					if (tileIndex == 7) {
						//tile ist direkt unter Mario
						player.desiredPosition = CGPoint(x: player.desiredPosition.x, y: player.desiredPosition.y + intersection.size.height);
						player.velocity = CGPoint(x: player.velocity.x, y: 0.0); //Geschwindigkeit auf 0 setzen, da Boden erreicht
						player.onGround = true;
					} else if (tileIndex == 1) {
						player.desiredPosition = CGPoint(x: player.desiredPosition.x, y: player.desiredPosition.y - intersection.size.height);
						player.velocity = CGPoint(x: player.velocity.x, y: 0.0);
					} else if (tileIndex == 3) {
						//tile ist links von Mario
						player.desiredPosition = CGPoint(x: player.desiredPosition.x + intersection.size.width, y: player.desiredPosition.y);
					} else if (tileIndex == 5) {
						//tile ist rechts von Mario
						player.desiredPosition = CGPoint(x: player.desiredPosition.x - intersection.size.width, y: player.desiredPosition.y);
					} else {
						if (intersection.size.width > intersection.size.height) {
							//tile liegt diagonal, wird aber vertikal behandelt
							player.velocity = CGPoint(x: player.velocity.x, y: 0.0);
							var intersectionHeight:CGFloat // TODO: never used
							if (tileIndex > 4) {
								intersectionHeight = intersection.size.height;
								player.onGround = true
							} else {
								intersectionHeight = -intersection.size.height;
							}
							player.desiredPosition = CGPoint(x: player.desiredPosition.x, y: player.desiredPosition.y + intersection.size.height );
						} else {
							//tile liegt diagonal, wird aber horizontal behandelt
							var intersectionWidth:CGFloat;
							if (tileIndex == 6 || tileIndex == 0) {
								intersectionWidth = intersection.size.width;
							} else {
								intersectionWidth = -intersection.size.width;
							}
							player.desiredPosition = CGPoint(x: player.desiredPosition.x  + intersectionWidth, y: player.desiredPosition.y);
						}
					}
				}
			}
		}
		player.position = player.desiredPosition;
	}

	/*
	* Ueberprueft auf Kollisionen zw Spieler und Spikes
	*/
	func handleSpikeCollision(_ player: Mario){

		if (self.gameOver){
			return
		}

		let indices = [7, 1, 3, 5, 0, 2, 6, 8]

		for item in indices {
			let tileIndex:NSInteger = item
			let playerRect:CGRect = player.collisionBoundingBox()
			let playerCoord:CGPoint = spikes.coord(for: player.desiredPosition)

			let tileColumn:NSInteger = tileIndex % 3
			let tileRow:NSInteger = tileIndex / 3

			let x = playerCoord.x + CGFloat(tileColumn - 1)
			let y = playerCoord.y + CGFloat(tileRow - 1)
			let tileCoord = CGPoint(x: x, y: y)

			let gid:NSInteger = self.tileGIDAtTileCoord(tileCoord, forLayer: spikes)

			if (gid != 0){
				let tileRect = tileRectFromTileCoords(tileCoord)
				if (playerRect.intersects(tileRect)){
					self.gameOver(false)
				}
			}
		}
	}

	/*
	* Wird aufgrufen wenn das Spiel vorbei ist und entscheidet, ob gewonnen oder verloren
	* Die View wird weitergeleitet zur replayView
	*/
	func gameOver(_ won:Bool){

		self.gameOver = true

		var endText: String

		if (won == true){
			endText = "You won!"
			let sceneNew = GameSceneLevel2(size: self.view!.bounds.size)
			self.view?.presentScene(sceneNew)
		} else {
			endText = "You died! :("
		}

		let endGameLabel = SKLabelNode(fontNamed: "Marker Felt")
		endGameLabel.text = endText
		endGameLabel.fontSize = 42
		endGameLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 1.7)

		self.addChild(endGameLabel)

		self.view?.addSubview(self.replayView!)

	}

	func checkForWin(){
		if (self.player.position.x > 3130){
			self.gameOver(true)
		}
	}

	private func loadGameControls() {
		let leftArrowButton = SKSpriteNode(imageNamed: "leftarrow")
		leftArrowButton.name = "leftArrowButton"
//		let xtoto = -(self.frame.width / 2)
//		let yToto = -(self.frame.height / 2)
		let xPos = (leftArrowButton.size.width / 2)  + 30 //xtoto + (leftArrowButton.size.width / 2)  + 30
		let yPos =  (leftArrowButton.size.height / 2) + 30 // yToto + (leftArrowButton.size.height / 2) + 30
		leftArrowButton.position = CGPoint(x: xPos, y: yPos)
		leftArrowButton.zPosition = 100
		addChild(leftArrowButton)

		let rightArrowButton = SKSpriteNode(imageNamed: "rightarrow")
		rightArrowButton.name = "rightArrowButton"
		rightArrowButton.position = CGPoint(x: leftArrowButton.position.x + leftArrowButton.size.width + 30, y: leftArrowButton.position.y)
		rightArrowButton.zPosition = 100
		addChild(rightArrowButton)


		let upArrowButton = SKSpriteNode(imageNamed: "uparrow")
		upArrowButton.name = "upArrowButton"
		upArrowButton.position = CGPoint(x: self.frame.width - 30 - upArrowButton.size.width / 2, y: leftArrowButton.position.y)
		upArrowButton.zPosition = 100
		addChild(upArrowButton)

//		let fireButton = SKSpriteNode(imageNamed: "fire")
//		fireButton.name = "attackButton"
//		fireButton.position = CGPoint(x: upArrowButton.position.x - fireButton.size.width - 30, y: leftArrowButton.position.y)
//		fireButton.zPosition = 100
//		addChild(fireButton)

	}

}

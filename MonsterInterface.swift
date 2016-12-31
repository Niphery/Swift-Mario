//
//  MonsterInterface.swift
//  Game
//
//  Created by Marvin Muuß on 17.04.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import Foundation
import SpriteKit

class Monster: SKSpriteNode {

	var tileMap:JSTileMap!
	var velocity = CGPoint(x: 0.0, y: 0.0)
	var desiredPosition = CGPoint(x: 0.0,y: 0.0)
	var onGround = false
	var mightJump = false
	var moveForward = true

	init(texture: SKTexture!) {
		super.init(texture: texture, color: .clear, size: texture.size())
		desiredPosition = position
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func update(_ delta: TimeInterval){
		checkForAndResolveCollisions(self, forLayer: tileMap.layerNamed("walls"))
	}

	func setTileMap(map: JSTileMap){
		tileMap = map
	}

	/*
	* Ueberprueft die Kollisionen zwischen dem Spieler und einem Layer
	* Bevorzugt mit walls auf denen sich der Spieler schließlich bewegt.
	* Dabei wird in der Reihenfolge unten, oben, links, rechts und schließlich diagonal ueberprueft
	*/
	func checkForAndResolveCollisions(_ monster: Monster!, forLayer layer: TMXLayer!){
		let indices = [7, 1, 3, 5, 0, 2, 6, 8]
		monster.onGround = false
		for item in indices {
			let tileIndex:NSInteger = item
			let monsterRect:CGRect = monster.collisionBoundingBox()
			let monsterCoord:CGPoint = layer.coord(for: monster.desiredPosition)

			//falls der Spieler aus der Map gefallen ist
			if (monsterCoord.y >= tileMap.mapSize.height - 1){
				//        self.gameOver(false)
				return
			}

			let tileColumn:NSInteger = tileIndex % 3
			let tileRow:NSInteger = tileIndex / 3

			let x = monsterCoord.x + CGFloat(tileColumn - 1)
			let y = monsterCoord.y + CGFloat(tileRow - 1)
			let tileCoord = CGPoint(x: x, y: y)

			let gid:NSInteger = tileGIDAtTileCoord(tileCoord, forLayer: layer)

			if (gid != 0){
				let tileRect = tileRectFromTileCoords(tileCoord)

				if (monsterRect.intersects(tileRect)) {
					let intersection: CGRect = monsterRect.intersection(tileRect);
					if (tileIndex == 7) {
						//tile ist direkt unter Mario
						monster.desiredPosition = CGPoint(x: monster.desiredPosition.x, y: monster.desiredPosition.y + intersection.size.height);
						monster.velocity = CGPoint(x: monster.velocity.x, y: 0.0); //Geschwindigkeit auf 0 setzen, da Boden erreicht
						monster.onGround = true;
					} else if (tileIndex == 1) {
						monster.desiredPosition = CGPoint(x: monster.desiredPosition.x, y: monster.desiredPosition.y - intersection.size.height);
						monster.velocity = CGPoint(x: monster.velocity.x, y: 0.0);
					} else if (tileIndex == 3) {
						//tile ist links von Mario
						monster.desiredPosition = CGPoint(x: monster.desiredPosition.x + intersection.size.width, y: monster.desiredPosition.y);
						monster.velocity = monster.velocity * -1
					} else if (tileIndex == 5) {
						//tile ist rechts von Mario
						monster.velocity = CGPoint(x: monster.velocity.x * -1, y: monster.velocity.y)
						monster.desiredPosition = CGPoint(x: monster.desiredPosition.x - intersection.size.width, y: monster.desiredPosition.y);
					} else {
						if (intersection.size.width > intersection.size.height) {
							//tile liegt diagonal, wird aber vertikal behandelt
							monster.velocity = CGPoint(x: monster.velocity.x, y: 0.0);
							var intersectionHeight:CGFloat // TODO: never used
							if (tileIndex > 4) {
								intersectionHeight = intersection.size.height;
								monster.onGround = true
							} else {
								intersectionHeight = -intersection.size.height;
							}
							monster.desiredPosition = CGPoint(x: monster.desiredPosition.x, y: monster.desiredPosition.y + intersection.size.height );
						} else {
							//tile liegt diagonal, wird aber horizontal behandelt
							var intersectionWidth:CGFloat;
							if (tileIndex == 6 || tileIndex == 0) {
								intersectionWidth = intersection.size.width;
							} else {
								intersectionWidth = -intersection.size.width;
							}
							monster.desiredPosition = CGPoint(x: monster.desiredPosition.x  + intersectionWidth, y: monster.desiredPosition.y);
						}
					}
				}
			}
		}
		monster.position = monster.desiredPosition;
	}


	func collisionBoundingBox() -> CGRect {
		let boundingBox = frame.insetBy(dx: 2, dy: 0)
		let diff = desiredPosition - position

		return boundingBox.offsetBy(dx: diff.x, dy: diff.y);
	}

	/*
	* Liefert den Urpsrungspixel eines Tiles zurueck.
	* Umrechnung weil TMXTiles oben links statt unten links starten
	*/
	func tileRectFromTileCoords(_ tileCoords: CGPoint) -> CGRect{
		let levelHeightInPixels = tileMap.mapSize.height * tileMap.tileSize.height
		var i = levelHeightInPixels - ((tileCoords.y + 1 ) * tileMap.tileSize.height) // TODO: never used
		let origin = CGPoint(x: tileCoords.x * tileMap.tileSize.width, y: levelHeightInPixels - ((tileCoords.y + 1 ) * tileMap.tileSize.height))
		return CGRect(x: origin.x, y: origin.y, width: tileMap.tileSize.width, height: tileMap.tileSize.height)
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
	* Stellt sicher, dass value in der Range von min und max liegt und beschraenkt es ggf.
	*/
	func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
		if (abs(value) < min){
			return min
		} else if (abs(value) > max){
			return max
		} else {
			return value
		}
	}

}

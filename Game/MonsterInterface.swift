//
//  MonsterInterface.swift
//  Game
//
//  Created by Marvin Muuß on 17.04.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import Foundation
import SpriteKit

class Monster : SKSpriteNode {
  
  var tileMap:JSTileMap!
  var velocity: CGPoint
  var desiredPosition: CGPoint
  var onGround = false
  var mightJump = false
  var moveForward = true
  
  init (texture:SKTexture){
    self.desiredPosition = CGPointMake(0.0,0.0)
    self.velocity = CGPointMake(0.0, 0.0)
    moveForward = true
    super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    self.desiredPosition = self.position
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func update (delta: NSTimeInterval){
    
    checkForAndResolveCollisions(self, forLayer: tileMap.layerNamed("walls"))
  }
  
  
  func setTileMap(map: JSTileMap){
    self.tileMap = map
  }
  
  /*
  * Ueberprueft die Kollisionen zwischen dem Spieler und einem Layer
  * Bevorzugt mit walls auf denen sich der Spieler schließlich bewegt.
  * Dabei wird in der Reihenfolge unten, oben, links, rechts und schließlich diagonal ueberprueft
  */
  func checkForAndResolveCollisions(monster: Monster!, forLayer layer: TMXLayer!){
    var indices = [7, 1, 3, 5, 0, 2, 6, 8]
    monster.onGround = false
    for item in indices {
      var tileIndex:NSInteger = item
      var monsterRect:CGRect = monster.collisionBoundingBox()
      var monsterCoord:CGPoint = layer.coordForPoint(monster.desiredPosition)
      
      //falls der Spieler aus der Map gefallen ist
      if (monsterCoord.y >= tileMap.mapSize.height - 1){
//        self.gameOver(false)
        return
      }
      
      var tileColumn:NSInteger = tileIndex % 3
      var tileRow:NSInteger = tileIndex / 3
      
      var x = monsterCoord.x + CGFloat(tileColumn - 1)
      var y = monsterCoord.y + CGFloat(tileRow - 1)
      var tileCoord = CGPointMake(x, y)
      
      var gid:NSInteger = self.tileGIDAtTileCoord(tileCoord, forLayer: layer)
      
      if (gid != 0){
        var tileRect = self.tileRectFromTileCoords(tileCoord)
        
        if (CGRectIntersectsRect(monsterRect, tileRect)) {
          var intersection: CGRect = CGRectIntersection(monsterRect, tileRect);
          if (tileIndex == 7) {
            //tile ist direkt unter Mario
            monster.desiredPosition = CGPointMake(monster.desiredPosition.x, monster.desiredPosition.y + intersection.size.height);
            monster.velocity = CGPointMake(monster.velocity.x, 0.0); //Geschwindigkeit auf 0 setzen, da Boden erreicht
            monster.onGround = true;
          } else if (tileIndex == 1) {
            monster.desiredPosition = CGPointMake(monster.desiredPosition.x, monster.desiredPosition.y - intersection.size.height);
            monster.velocity = CGPointMake(monster.velocity.x, 0.0);
          } else if (tileIndex == 3) {
            //tile ist links von Mario
            monster.desiredPosition = CGPointMake(monster.desiredPosition.x + intersection.size.width, monster.desiredPosition.y);
            monster.velocity = monster.velocity * -1
          } else if (tileIndex == 5) {
            //tile ist rechts von Mario
            monster.velocity = CGPointMake(monster.velocity.x * -1, monster.velocity.y)
            monster.desiredPosition = CGPointMake(monster.desiredPosition.x - intersection.size.width, monster.desiredPosition.y);
          } else {
            if (intersection.size.width > intersection.size.height) {
              //tile liegt diagonal, wird aber vertikal behandelt
              monster.velocity = CGPointMake(monster.velocity.x, 0.0);
              var intersectionHeight:CGFloat;
              if (tileIndex > 4) {
                intersectionHeight = intersection.size.height;
                monster.onGround = true
              } else {
                intersectionHeight = -intersection.size.height;
              }
              monster.desiredPosition = CGPointMake(monster.desiredPosition.x, monster.desiredPosition.y + intersection.size.height );
            } else {
              //tile liegt diagonal, wird aber horizontal behandelt
              var intersectionWidth:CGFloat;
              if (tileIndex == 6 || tileIndex == 0) {
                intersectionWidth = intersection.size.width;
              } else {
                intersectionWidth = -intersection.size.width;
              }
              monster.desiredPosition = CGPointMake(monster.desiredPosition.x  + intersectionWidth, monster.desiredPosition.y);
            }
          }
        }
      }
    }
    monster.position = monster.desiredPosition;
  }


  func collisionBoundingBox() -> CGRect {
    var boundingBox = CGRectInset(self.frame, 2, 0)
    var diff = self.desiredPosition - self.position
    
    return CGRectOffset(boundingBox, diff.x, diff.y);
  }
  
  /*
  * Liefert den Urpsrungspixel eines Tiles zurueck.
  * Umrechnung weil TMXTiles oben links statt unten links starten
  */
  func tileRectFromTileCoords(tileCoords: CGPoint) -> CGRect{
    var levelHeightInPixels = tileMap.mapSize.height * tileMap.tileSize.height
    var i = levelHeightInPixels - ((tileCoords.y + 1 ) * tileMap.tileSize.height)
    var origin = CGPointMake(tileCoords.x * tileMap.tileSize.width, levelHeightInPixels - ((tileCoords.y + 1 ) * tileMap.tileSize.height))
    return CGRectMake(origin.x, origin.y, tileMap.tileSize.width, tileMap.tileSize.height)
  }
  
  /*
  * Liefer GID des Tiles abhaengig der Kooridnate zurueck.
  * Die GID ist eine Nummer, die ein Bild von der Menge der Tiles darstellt
  */
  func tileGIDAtTileCoord(coord: CGPoint, forLayer layer: TMXLayer!) -> Int {
    var layerInfo:TMXLayerInfo = layer.layerInfo
    var i = layerInfo.tileGidAtCoord(coord)
    return i
  }

  /*
  * Stellt sicher, dass value in der Range von min und max liegt und beschraenkt es ggf.
  */
  func clamp(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    if (abs(value) < min){
      return min
    } else if (abs(value) > max){
      return max
    } else {
      return value
    }
  }
  
}

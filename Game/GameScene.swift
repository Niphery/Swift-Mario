//
//  GameScene.swift
//  Game
//
//  Created by Marvin Muuß on 07.01.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import SpriteKit


struct PhysicsCategory {
  static let None      : UInt32 = 0
  static let All       : UInt32 = UInt32.max
  static let Blocks   : UInt32 = 0b1       // 1
  static let Lava : UInt32 = 0b10
  static let Player: UInt32 = 0b11      // 2
  static let Monster: UInt32 = 0b100
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  //  let player = SKSpriteNode(imageNamed: "player")
  let player = Player()
  var tileMap = JSTileMap(named: "level1.tmx")
  var previousUpdateTime: CFTimeInterval = 0.0
//  var walls: TMXLayer
  
  override func didMoveToView(view: SKView) {
    /* Setup your scene here */
    /*    let myLabel = SKLabelNode(fontNamed:"Chalkduster")
    myLabel.text = "Hello, World!";
    myLabel.fontSize = 65;
    myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
    
    self.addChild(myLabel) */
    
    backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.95, alpha: 1.0)
    
    self.anchorPoint = CGPoint(x: 0, y: 0)
    self.position = CGPoint(x: 0, y: 0)
    
    let rect = tileMap.calculateAccumulatedFrame()
    tileMap.position = CGPoint(x: 0, y: 0)
    
    
    // 3
    player.position = CGPoint(x: 100, y: 50)
    player.zPosition = 15
    
    // 4
    
    tileMap.addChild(player)
    addChild(tileMap)
    
    
    physicsWorld.gravity = CGVectorMake(0, -1)
    physicsWorld.contactDelegate = self
    
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    /* Called when a touch begins */
    
    /*  for touch: AnyObject in touches {
    let location = touch.locationInNode(self)
    
    let sprite = SKSpriteNode(imageNamed:"Spaceship")
    
    sprite.xScale = 0.5
    sprite.yScale = 0.5
    sprite.position = location
    
    let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
    
    sprite.runAction(SKAction.repeatActionForever(action))
    
    self.addChild(sprite)
    } */
  }
  
  override func update(currentTime: CFTimeInterval) {
    /* Called before each frame is rendered */
    var delta = currentTime - previousUpdateTime
    
    if (delta > 0.02){
      delta = 0.02
    }
    previousUpdateTime = currentTime
    
    player.update(delta)
    
    var walls = tileMap.layerNamed("walls")
    self.checkForAndResolveCollisionsForPlayer(self.player, forLayer: walls)
    
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
  }
  
  func tileRectFromTileCoords(tileCoords: CGPoint) -> CGRect{
    var levelHeightInPixels = tileMap.mapSize.height * tileMap.tileSize.height
    var i = levelHeightInPixels - ((tileCoords.y + 1 ) * tileMap.tileSize.height)
    var origin = CGPointMake(tileCoords.x * tileMap.tileSize.width, levelHeightInPixels - ((tileCoords.y + 1 ) * tileMap.tileSize.height))
    return CGRectMake(origin.x, origin.y, tileMap.tileSize.width, tileMap.tileSize.height)
  }
  
  func tileGIDAtTileCoord(coord: CGPoint, forLayer layer: TMXLayer!) -> Int {
    var layerInfo:TMXLayerInfo = layer.layerInfo
    var i = layerInfo.tileGidAtCoord(coord)
    return i
  }
  
  func checkForAndResolveCollisionsForPlayer(player: Player!, forLayer layer: TMXLayer!){
    var indices = [7, 1, 3, 5, 0, 2, 6, 8]
    
    for item in indices {
      var tileIndex:NSInteger = item
      var playerRect:CGRect = player.collisionBoundingBox
      var playerCoord:CGPoint = layer.coordForPoint(player.position)
      
      var tileColumn:NSInteger = tileIndex % 3
      var tileRow:NSInteger = tileIndex / 3
      
      var x = playerCoord.x + CGFloat(tileColumn - 1)
      var y = playerCoord.y + CGFloat(tileRow - 1)
      var tileCoord = CGPointMake(x, y)
      
      var gid:NSInteger = self.tileGIDAtTileCoord(tileCoord, forLayer: layer)
      
      if (gid != 0){
        var tileRect = self.tileRectFromTileCoords(tileCoord)
      print("Hallo")
      NSLog("GID %ld, Tile Coord %@, Tile Rect %@, player rect %@", gid, NSStringFromCGPoint(tileCoord), NSStringFromCGRect(tileRect), NSStringFromCGRect(playerRect))
      }
    }
    
  }

//- (NSInteger)tileGIDAtTileCoord:(CGPoint)coord forLayer:(TMXLayer *)layer {
//  TMXLayerInfo *layerInfo = layer.layerInfo;
//  return [layerInfo tileGidAtCoord:coord];
//}
}

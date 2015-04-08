//
//  GameScene.swift
//  Game
//
//  Created by Marvin Muuß on 07.01.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import SpriteKit


/* struct PhysicsCategory {
  static let None      : UInt32 = 0
  static let All       : UInt32 = UInt32.max
  static let Blocks   : UInt32 = 0b1       // 1
  static let Lava : UInt32 = 0b10
  static let Player: UInt32 = 0b11      // 2
  static let Monster: UInt32 = 0b100
} */

class GameScene: SKScene, SKPhysicsContactDelegate, ReplaySceneDelegate {
  
  //  let player = SKSpriteNode(imageNamed: "player")
  let player = Player()
  var tileMap = JSTileMap(named: "level1.tmx")
  var spikes = TMXLayer()
  var walls = TMXLayer()
  var previousUpdateTime: CFTimeInterval = 0.0
  var gameOver = false
  var replayView: SKView?
  
  func replaySceneDidFinish(myScene: ReplayScene, command: String){
    myScene.view?.removeFromSuperview()
    if (command == "Restart"){
      let sceneNew = GameScene(size: self.view!.bounds.size)
      self.view?.presentScene(sceneNew)
    }
  }

  override func didMoveToView(view: SKView) {
    
    self.replayView = SKView(frame: CGRectMake(self.frame.size.width / 4, self.frame.size.height / 4,
                                                self.frame.size.width / 2, self.frame.size.height / 2))
    let replayScene = ReplayScene(size: CGSizeMake(self.frame.size.width / 2, self.frame.size.height / 2))
    replayScene.thisDelegate = self
    
    self.replayView!.presentScene(replayScene)
    
    SKTAudio.sharedInstance().playBackgroundMusic("level1.mp3")
    
    self.userInteractionEnabled = true
    
    backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.95, alpha: 1.0)
    
    self.anchorPoint = CGPoint(x: 0, y: 0)
    self.position = CGPoint(x: 0, y: 0)
    
    let rect = tileMap.calculateAccumulatedFrame()
    tileMap.position = CGPoint(x: 0, y: 0)
    
    player.position = CGPoint(x: 100, y: 50)
    player.zPosition = 15
    
    tileMap.addChild(player)
    spikes = tileMap.layerNamed("hazards")
    walls = tileMap.layerNamed("walls")
    addChild(tileMap)
    
    physicsWorld.gravity = CGVectorMake(0, -1)
    physicsWorld.contactDelegate = self
    
  }
  
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    /* Called when a touch begins */
    for touch: AnyObject in touches {
      var touchLocation = touch.locationInNode(self)
      if (touchLocation.x > self.size.width / 2.0){
        self.player.mightAsWellJump = true
      } else {
        self.player.marchForward = true
      }
    }
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    for touch: AnyObject in touches {
      var halfWidth:CGFloat = self.size.width / 2.0
      var touchLocation:CGPoint = touch.locationInNode(self)
      
      var previousTouchLocation = touch.previousLocationInNode(self)
      
      if (touchLocation.x > halfWidth && previousTouchLocation.x <= halfWidth){
        self.player.marchForward = false
        self.player.mightAsWellJump = true
      } else if (previousTouchLocation.x > halfWidth && touchLocation.x <= halfWidth){
        self.player.marchForward = true
        self.player.mightAsWellJump = false
      }
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    for touch: AnyObject in touches {
      var touchLocation = touch.locationInNode(self)
      if (touchLocation.x > self.size.width / 2.0){
        self.player.mightAsWellJump = false
      } else {
        self.player.marchForward = false
      }
    }
  }
  
  override func update(currentTime: CFTimeInterval) {
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
    
//    var walls = tileMap.layerNamed("walls")
    self.checkForAndResolveCollisionsForPlayer(self.player, forLayer: walls)
    self.handleSpikeCollision(self.player)
    self.checkForWin()
    
  }
  
  func setViewpointCenter(position: CGPoint){
    var x = max(position.x, self.size.width / 2)
    var y = max(position.y, self.size.height / 2)
    
    x = min(x,(self.tileMap.mapSize.width * self.tileMap.tileSize.width) - self.size.width / 2)
    y = min(y,(self.tileMap.mapSize.height * self.tileMap.tileSize.height) - self.size.height / 2)
    
    var actualPosition = CGPointMake(x,y)
    var centerView = CGPointMake(self.size.width / 2, self.size.height / 2)
    var view = centerView - actualPosition
    
    self.tileMap.position = view
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
    player.onGround = false
    for item in indices {
      var tileIndex:NSInteger = item
      var playerRect:CGRect = player.collisionBoundingBox()
      var playerCoord:CGPoint = layer.coordForPoint(player.desiredPosition)
      
      if (playerCoord.y >= tileMap.mapSize.height - 1){
        self.gameOver(false)
        return
      }
      
      var tileColumn:NSInteger = tileIndex % 3
      var tileRow:NSInteger = tileIndex / 3
      
      var x = playerCoord.x + CGFloat(tileColumn - 1)
      var y = playerCoord.y + CGFloat(tileRow - 1)
      var tileCoord = CGPointMake(x, y)
      
      var gid:NSInteger = self.tileGIDAtTileCoord(tileCoord, forLayer: layer)
      
      if (gid != 0){
        var tileRect = self.tileRectFromTileCoords(tileCoord)
        
        //1
        if (CGRectIntersectsRect(playerRect, tileRect)) {
          var intersection: CGRect = CGRectIntersection(playerRect, tileRect);
          //2
          if (tileIndex == 7) {
            //tile is directly below Koala
            player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height);
            player.velocity = CGPointMake(player.velocity.x, 0.0); ////Here
            player.onGround = true;
          } else if (tileIndex == 1) {
            //tile is directly above Koala
            player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y - intersection.size.height);
          } else if (tileIndex == 3) {
            //tile is left of Koala
            player.desiredPosition = CGPointMake(player.desiredPosition.x + intersection.size.width, player.desiredPosition.y);
          } else if (tileIndex == 5) {
            //tile is right of Koala
            player.desiredPosition = CGPointMake(player.desiredPosition.x - intersection.size.width, player.desiredPosition.y);
            //3
          } else {
            if (intersection.size.width > intersection.size.height) {
              //tile is diagonal, but resolving collision vertically
              //4
              player.velocity = CGPointMake(player.velocity.x, 0.0); ////Here
              var intersectionHeight:CGFloat;
              if (tileIndex > 4) {
                intersectionHeight = intersection.size.height;
                player.onGround = true
              } else {
                intersectionHeight = -intersection.size.height;
              }
              player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height );
            } else {
              //tile is diagonal, but resolving horizontally
              var intersectionWidth:CGFloat;
              if (tileIndex == 6 || tileIndex == 0) {
                intersectionWidth = intersection.size.width;
              } else {
                intersectionWidth = -intersection.size.width;
              }
              player.desiredPosition = CGPointMake(player.desiredPosition.x  + intersectionWidth, player.desiredPosition.y);
            }
          }
        }
      }
    }
    //5
    player.position = player.desiredPosition;
  }
  
  func handleSpikeCollision(player: Player){
    
    if (self.gameOver){
      return
    }
    
    var indices = [7, 1, 3, 5, 0, 2, 6, 8]
    
    for item in indices {
      var tileIndex:NSInteger = item
      var playerRect:CGRect = player.collisionBoundingBox()
      var playerCoord:CGPoint = spikes.coordForPoint(player.desiredPosition)
      
      var tileColumn:NSInteger = tileIndex % 3
      var tileRow:NSInteger = tileIndex / 3
      
      var x = playerCoord.x + CGFloat(tileColumn - 1)
      var y = playerCoord.y + CGFloat(tileRow - 1)
      var tileCoord = CGPointMake(x, y)
      
      var gid:NSInteger = self.tileGIDAtTileCoord(tileCoord, forLayer: spikes)
      
      if (gid != 0){
        var tileRect = tileRectFromTileCoords(tileCoord)
        if (CGRectIntersectsRect(playerRect, tileRect)){
          self.gameOver(false)
        }
      }
    }
  }
  
  func gameOver(won:Bool){
    
    self.gameOver = true
    
    var endText: String
    
    if (won == true){
      endText = "You won, whoho!"
    } else {
      endText = "You died! :("
    }
    
    var endGameLabel = SKLabelNode(fontNamed: "Marker Felt")
    endGameLabel.text = endText
    endGameLabel.fontSize = 42
    endGameLabel.position = CGPointMake(self.size.width / 2, self.size.height / 1.7)
    
    self.addChild(endGameLabel)
    
    self.view?.addSubview(self.replayView!)
    
 /*   var replayButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
    replayButton.tag = 321
    var replayImage = UIImage(named: "replay")
    
    var imageWidth = replayImage?.size.width
    var imageHeight = replayImage?.size.height
    
    replayButton.setImage(replayImage, forState: UIControlState.Normal)
    replayButton.addTarget(self, action: "replay:", forControlEvents: UIControlEvents.TouchUpInside)
    replayButton.frame = CGRectMake(self.size.width / 2.0 - imageWidth! / 2.0, self.size.height / 2.0 - imageHeight! / 2.0, imageWidth!, imageHeight!)
    
    self.view?.addSubview(replayButton)
    */
  }
  
  func checkForWin(){
    if (self.player.position.x > 3130){
      self.gameOver(true)
    }
  }
  
}

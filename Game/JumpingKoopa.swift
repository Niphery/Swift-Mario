//
//  Mario.swift
//  Game
//
//  Created by Marvin Muuß on 05.04.15.
//  Copyright (c) 2015 Marvin Muuss. All rights reserved.
//

import Foundation

class JumpingKoopa : Monster {

	init() {
		let texture = SKTexture(imageNamed: "Koopa")
		super.init(texture: texture)
		mightJump = true
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func update(_ delta: TimeInterval){
		let gravity = CGPoint(x: 0.0, y: -450.0)
		let gravityStep = gravity * CGFloat(delta)
		var v:CGFloat = 0.0
		if (velocity.x < 0){
			v = -400.0
		} else {
			v = 400.0
		}
		let forwardMove = CGPoint(x: v, y: 0.0)
		let forwardStep = forwardMove * CGFloat(delta)

		velocity = velocity + gravityStep

		velocity = CGPoint(x: velocity.x * 0.9, y: velocity.y)

		let jumpHeight = CGPoint(x: 0, y: 170)
		let restrictJump:CGFloat = 150

		if (mightJump && onGround) {
			velocity = velocity + jumpHeight
		} else if (!mightJump && velocity.y > restrictJump) {
			velocity = CGPoint(x: velocity.x, y: restrictJump)
		}

		if (moveForward){
			velocity = velocity + forwardStep
		}

		let minMovement = CGPoint(x: 0.0,y: -450)
		let maxMovement = CGPoint(x: 120,y: 250)

		velocity = CGPoint(x: clamp(velocity.x, min: minMovement.x, max: maxMovement.x), y: clamp(velocity.y, min: minMovement.y, max: maxMovement.y))

		let velocityStep = velocity * CGFloat(delta)

		desiredPosition = position + velocityStep

		super.update(delta)
	}
	
}

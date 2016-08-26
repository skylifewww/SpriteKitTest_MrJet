//
//  AnimationClass.swift
//  SpriteKitTest
//
//  Created by Константин on 05.08.16.
//  Copyright © 2016 Константин. All rights reserved.
//

import Foundation
import SpriteKit

class AnimationClass {
    
    func scaleZdirection(sprite: SKSpriteNode) {
        sprite.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.scale(by: 2.0, duration: 0.5),
                SKAction.scale(to: 1.0, duration: 1.0)
                ])
            ))
    }
    
    func redColorAnimation(sprite: SKSpriteNode, animDuration: TimeInterval) {
        sprite.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.colorize(with: SKColor.red, colorBlendFactor: 1.0, duration: animDuration),
                SKAction.colorize(withColorBlendFactor: 0.0, duration: animDuration)
                ])
            ))
    }
    
}

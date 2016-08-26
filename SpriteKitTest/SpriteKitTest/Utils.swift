//
//  Utils.swift
//  SpriteKitTest
//
//  Created by Константин on 04.08.16.
//  Copyright © 2016 Константин. All rights reserved.
//

import Foundation
import CoreGraphics

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}


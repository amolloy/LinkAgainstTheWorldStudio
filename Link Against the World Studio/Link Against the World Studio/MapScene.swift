//
//  MapScene.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/10/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation
import SpriteKit

class MapScene : SKScene
{
	override func mouseDragged(_ theEvent: NSEvent)
	{
		if let node = children.first
		{
			node.position = CGPoint(x: node.position.x + theEvent.deltaX, y: node.position.y - theEvent.deltaY)
		}
	}
}

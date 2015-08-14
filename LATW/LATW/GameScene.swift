//
//  GameScene.swift
//  LATW
//
//  Created by Andrew Molloy on 7/29/15.
//  Copyright (c) 2015 Andrew Molloy. All rights reserved.
//

import SpriteKit
import TileMap

class GameScene: SKScene
{
	lazy var tileMap : TileMap? =
	{
		let bundle = NSBundle(forClass: GameScene.self)
		guard let testMapPath = bundle.pathForResource("Test", ofType: "fmp") else
		{
			return nil
		}

		guard let tileMapFile = TileMap(path: testMapPath) else
		{
			return nil
		}

		do
		{
			try tileMapFile.open()
		}
		catch let e
		{
	//		XCTFail("tileMapFile.open() threw \(e)")
		}
		do
		{
			try tileMapFile.loadChunks()
		}
		catch let e
		{
		//	XCTFail("tileMapFile.loadChunks() threw \(e)")
		}
		return tileMapFile
	}()

    override func didMoveToView(view: SKView)
	{
		guard let tileMap = self.tileMap else
		{
			assertionFailure("Couldn't load tile map.")
			return
		}
		let renderer = TileMapSKRenderer(tileMap: tileMap)
		let node : TileMapSKNode?
		do
		{
			node = try renderer.node()
		}
		catch
		{
			assertionFailure("Couldn't create SKNode from TileMap")
			return
		}
		if let node = node
		{
			addChild(node)
		}
	}

	override func mouseDragged(theEvent: NSEvent)
	{
		if let node = children.first
		{
			node.position = CGPoint(x: node.position.x + theEvent.deltaX, y: node.position.y - theEvent.deltaY)
		}
	}
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}

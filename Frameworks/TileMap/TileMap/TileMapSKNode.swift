//
//  TileMapSKNode.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/14/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation
import SpriteKit

protocol SpriteKitTileable : Tileable
{
	func spriteNode(x: Int, y: Int, baseZ: Int, textureAtlas: SKTextureAtlas) -> SKNode
}

extension BlockData.BlockStructure : SpriteKitTileable
{
	func spriteNode(index: Int, textureAtlas: SKTextureAtlas) -> SKSpriteNode
	{
		let texture = textureAtlas.textureNamed(String(index))
		return SKSpriteNode(texture: texture)
	}

	func spriteNode(x: Int, y: Int, baseZ: Int, textureAtlas: SKTextureAtlas) -> SKNode
	{
		let node = SKNode()

		let bgNode = spriteNode(backgroundIndex, textureAtlas: textureAtlas)
		bgNode.anchorPoint = CGPointZero
		bgNode.position = CGPoint(x: x, y: y)
		bgNode.zPosition = CGFloat(baseZ)

		node.addChild(bgNode)

		var z = baseZ
		for fgIndex in foregroundIndices
		{
			++z
			if fgIndex != 0
			{
				let fgNode = spriteNode(fgIndex, textureAtlas: textureAtlas)
				fgNode.anchorPoint = CGPointZero
				fgNode.position = CGPoint(x: x, y: y)
				fgNode.zPosition = CGFloat(z)

				node.addChild(fgNode)
			}
		}

		return node
	}
}

extension AnimationData.AnimationStructure : SpriteKitTileable
{
	func spriteNode(index: Int, textureAtlas: SKTextureAtlas) -> SKSpriteNode
	{
		let texture = textureAtlas.textureNamed(String(index))
		return SKSpriteNode(texture: texture)
	}

	func spriteNode(x: Int, y: Int, baseZ: Int, textureAtlas: SKTextureAtlas) -> SKNode
	{
		let node = SKNode()

		// TODO Actual animation
		let gfxNode = spriteNode(frames[0], textureAtlas: textureAtlas)
		gfxNode.anchorPoint = CGPointZero
		gfxNode.position = CGPoint(x: x, y: y)
		gfxNode.zPosition = CGFloat(baseZ)

		node.addChild(gfxNode)

		return node
	}
}

public class TileMapSKNode : SKNode
{
	let tileMap : TileMap
	let textureAtlas : SKTextureAtlas

	init(tileMap: TileMap, textureAtlas: SKTextureAtlas)
	{
		self.tileMap = tileMap
		self.textureAtlas = textureAtlas
		super.init()
	}

	public required init?(coder: NSCoder)
	{
		assertionFailure()
		tileMap = TileMap(path: "")!
		textureAtlas = SKTextureAtlas()
		super.init()
		return nil
	}

	func buildTilesForLayer(layer: Layer) -> SKNode?
	{
		guard let mapHeader = tileMap.mapHeader else
		{
			return nil
		}

		let node = SKNode()

		for y in 0..<mapHeader.mapSize.height
		{
			let yPos = y * mapHeader.blockSize.height

			for x in 0..<mapHeader.mapSize.width
			{
				let tile = layer.tiles[mapHeader.mapSize.height - 1 - y][x]
				if let tile = tile as? SpriteKitTileable
				{
					let xPos = x * mapHeader.blockSize.width
					let tileNode = tile.spriteNode(xPos, y: yPos, baseZ: 0, textureAtlas: textureAtlas)
					node.addChild(tileNode)
				}
				else
				{
					assertionFailure()
				}
			}
		}

		return node
	}
}

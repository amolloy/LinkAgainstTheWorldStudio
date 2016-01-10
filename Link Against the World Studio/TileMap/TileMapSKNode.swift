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
	func spriteNodeAtX(x: Int, y: Int, baseZ: Int, textureAtlas: SKTextureAtlas, blocks: [BlockData.BlockStructure]) -> SKNode
}

extension SpriteKitTileable
{
	func spriteNode(index: Int, textureAtlas: SKTextureAtlas) -> SKSpriteNode
	{
		let texture = textureAtlas.textureNamed(String(index))
		return SKSpriteNode(texture: texture)
	}
}

extension BlockData.BlockStructure : SpriteKitTileable
{
	func spriteNodeAtX(x: Int, y: Int, baseZ: Int, textureAtlas: SKTextureAtlas, blocks: [BlockData.BlockStructure]) -> SKNode
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
	func spriteNodeAtX(x: Int, y: Int, baseZ: Int, textureAtlas: SKTextureAtlas, blocks: [BlockData.BlockStructure]) -> SKNode
	{
		// TODO Actual animation
		let block = blocks[frames[frameIndex]]
		return block.spriteNodeAtX(x, y: y, baseZ: baseZ, textureAtlas: textureAtlas, blocks: blocks)
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
		guard let blocks = tileMap.blockData?.blockStructures else
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
					let tileNode = tile.spriteNodeAtX(xPos,
						y: yPos,
						baseZ: 0,
						textureAtlas: textureAtlas,
						blocks: blocks)
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

//
//  MapSKRenderer.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/9/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation
import LATWMap
import SpriteKit
import CrossPlatform

struct SurroundingTiles
{
	let north : Tileable?
	let northeast : Tileable?
	let east : Tileable?
	let southeast : Tileable?
	let south : Tileable?
	let southwest : Tileable?
	let west : Tileable?
	let northwest : Tileable?
}

protocol SpriteKitTileable : Tileable
{
	func nodeAt(_ coordinate: TileLayer.Coordinate, textureAtlas: SKTextureAtlas, surroundingTiles: SurroundingTiles) -> SKNode?
}

extension TileSet
{
	func textureAtlas() -> SKTextureAtlas?
	{
		typealias Image = CrossPlatform.Image
		var textureInfos = [String : Image]()
		for i in 0..<tileCount
		{
			let image = imageForTileAtIndex(i)
			textureInfos[String(i)] = image
		}

		return SKTextureAtlas(dictionary: textureInfos)
	}
}

extension Array
{
	subscript (safe index: Int) -> Element?
	{
		return indices ~= index ? self[index] : nil
	}
}

public class TileLayerNode : SKNode
{
	let tileLayer : TileLayer
	let textureAtlas : SKTextureAtlas

	public init?(tileLayer: TileLayer)
	{
		self.tileLayer = tileLayer

		guard let tileSet = self.tileLayer.tileSet,
			  let textureAtlas = tileSet.textureAtlas() else
		{
			self.textureAtlas = SKTextureAtlas()
			super.init()
			return nil
		}

		self.textureAtlas = textureAtlas

		super.init()

		self.zPosition = CGFloat(tileLayer.zIndex)
		
		buildMapNodes()
	}

	public required init?(coder aDecoder: NSCoder)
	{
		assertionFailure()
		self.tileLayer = TileLayer()
		self.textureAtlas = SKTextureAtlas()
		super.init()
		return nil
	}

	func buildMapNodes()
	{
		guard let tileSet = self.tileLayer.tileSet else
		{
			return
		}

		for y in 0..<tileLayer.size.height
		{
			let yPos = y * tileSet.tileHeight

			let northRow = tileLayer.tiles[safe: y - 1]
			let curRow = tileLayer.tiles[y]
			let southRow = tileLayer.tiles[safe: y + 1]

			for x in 0..<tileLayer.size.width
			{
				let tile = curRow[x]
				if let tile = tile as? SpriteKitTileable
				{
					let xPos = x * tileSet.tileWidth
					let surroundingTiles = SurroundingTiles(
						north: northRow?[safe: x],
						northeast: northRow?[safe: x + 1],
						east: curRow[safe: x + 1],
						southeast: southRow?[safe: x + 1],
						south: southRow?[safe: x],
						southwest: southRow?[safe: x - 1],
						west: curRow[safe: x - 1],
						northwest: northRow?[safe: x - 1]
					)

					if let tileNode = tile.nodeAt(TileLayer.Coordinate(x: x, y: y),
						textureAtlas: textureAtlas,
						surroundingTiles: surroundingTiles)
					{
						tileNode.position = CGPoint(x: xPos, y: yPos)
						addChild(tileNode)
					}
				}
				else
				{
					assertionFailure()
				}
			}
		}
	}
}

extension EmptyTile : SpriteKitTileable
{
	func nodeAt(_ coordinate: TileLayer.Coordinate, textureAtlas: SKTextureAtlas, surroundingTiles: SurroundingTiles) -> SKNode?
	{
		return nil
	}
}

extension StaticTile : SpriteKitTileable
{
	func nodeAt(_ coordinate: TileLayer.Coordinate, textureAtlas: SKTextureAtlas, surroundingTiles: SurroundingTiles) -> SKNode?
	{
		let texture = textureAtlas.textureNamed(String(index))
		return SKSpriteNode(texture: texture)
	}
}

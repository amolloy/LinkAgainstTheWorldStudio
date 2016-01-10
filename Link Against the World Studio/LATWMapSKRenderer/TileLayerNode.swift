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
	func nodeAt(coordinate: TileLayer.Coordinate, textures: [SKTexture], surroundingTiles: SurroundingTiles) -> SKNode?
}

extension TileSet
{
	func textureCoordinatesForTileAtIndex(index: Int) -> CGRect
	{
		guard let image = image else
		{
			return CGRectZero
		}
		let xFactor = 1.0 / image.size.width
		let yFactor = 1.0 / image.size.height
		let unnormalizedCoordinates = self.coordinatesForTileAtIndex(index)

		return CGRect(x: unnormalizedCoordinates.origin.x * xFactor,
			y: unnormalizedCoordinates.origin.y * yFactor,
			width: unnormalizedCoordinates.size.width * xFactor,
			height: unnormalizedCoordinates.size.height * yFactor)
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
	let textures : [SKTexture]

	public init?(tileLayer: TileLayer)
	{
		self.tileLayer = tileLayer

		guard let tileSet = self.tileLayer.tileSet,
			  let masterImage = tileSet.image?.cgImage else
		{
			self.textures = [SKTexture]()
			super.init()
			return nil
		}
		let masterTexture = SKTexture(CGImage: masterImage)
		var newTextures = [SKTexture]()
		newTextures.reserveCapacity(tileSet.tileCount)
		for i in 0..<tileSet.tileCount
		{
			let coords = tileSet.textureCoordinatesForTileAtIndex(i)
			let texture = SKTexture(rect: coords, inTexture: masterTexture)
			newTextures.append(texture)
		}
		self.textures = newTextures

		super.init()

		buildMapNodes()
	}

	public required init?(coder aDecoder: NSCoder)
	{
		assertionFailure()
		self.tileLayer = TileLayer()
		self.textures = [SKTexture]()
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
						textures: textures,
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
	func nodeAt(coordinate: TileLayer.Coordinate, textures: [SKTexture], surroundingTiles: SurroundingTiles) -> SKNode?
	{
		return nil
	}
}

extension StaticTile : SpriteKitTileable
{
	func nodeAt(coordinate: TileLayer.Coordinate, textures: [SKTexture], surroundingTiles: SurroundingTiles) -> SKNode?
	{
		return SKSpriteNode(texture: textures[index])
	}
}

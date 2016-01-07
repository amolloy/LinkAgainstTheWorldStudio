//
//  Map+TileMapImport.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/2/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation
import TileMap
import LATWMap
import CrossPlatform
import ImageUtilities

func textureAtlasWithBlockSize(blockSize: TileMap.Size, textures: [Image]) -> Image?
{
	let textureCount = textures.count
	let texturesWide = Int(ceil(sqrt(CGFloat(textureCount))))
	let texturesHigh = (textureCount + texturesWide - 1) / texturesWide

	let atlasSize = TileMap.Size(texturesWide * blockSize.width, texturesHigh * blockSize.height)

	let cs = CGColorSpaceCreateDeviceRGB()

	let ctx = CGBitmapContextCreate(nil,
		atlasSize.width,
		atlasSize.height,
		8,
		atlasSize.width * 4,
		cs,
		CGImageAlphaInfo.PremultipliedLast.rawValue)

	CGContextClearRect(ctx, CGRect(x: 0, y: 0, width: CGFloat(atlasSize.width), height: CGFloat(atlasSize.height)))

	for i in 0..<textureCount
	{
		let texture = textures[i]
		let column = i % texturesWide
		let row = i / texturesWide
		let textureRect = CGRect(x: CGFloat(column * blockSize.width),
			y: CGFloat(row * blockSize.height),
			width: CGFloat(blockSize.width),
			height: CGFloat(blockSize.height))
		CGContextDrawImage(ctx, textureRect, texture.cgImage)
	}

	guard let cgImage = CGImageCreateWithCGContext(ctx) else { return nil }
	
	return Image(CGImage: cgImage, size: NSSize(atlasSize))
}

extension TileMap
{
	func tileLayersForLayer(layer : Layer, tileSet: TileSet) -> [TileLayer]?
	{
		guard let mapHeader = mapHeader else
		{
			return nil
		}

		class TileLayerWork
		{
			var origin : Layer
			var used : Bool
			let size : Size
			var tileLayer : TileLayer?
			var tileSet : TileSet

			init(origin: Layer, size: Size, tileSet: TileSet)
			{
				self.origin = origin
				self.used = false
				self.size = size
				self.tileSet = tileSet
			}

			func setTileAtX(x: Int, y: Int, tile: LATWMap.Tileable)
			{
				if tileLayer == nil
				{
					let emptyTile : LATWMap.Tileable = EmptyTile()
					let tiles = Array(count: size.height, repeatedValue:
						Array(count: size.width, repeatedValue:emptyTile))

					used = true

					tileLayer = TileLayer(name: "", tiles: tiles, tileSet: tileSet)
				}
				guard let tileLayer = tileLayer else { return }
				tileLayer.setTileAtX(x, y: y, tile: tile)
			}
		}

		var workTileLayers = [TileLayerWork(origin: layer, size:mapHeader.mapSize, tileSet: tileSet),
						  TileLayerWork(origin: layer, size:mapHeader.mapSize, tileSet: tileSet),
						  TileLayerWork(origin: layer, size:mapHeader.mapSize, tileSet: tileSet),
						  TileLayerWork(origin: layer, size:mapHeader.mapSize, tileSet: tileSet)]

		for y in 0..<mapHeader.mapSize.height
		{
			for x in 0..<mapHeader.mapSize.width
			{
				let tile = layer.tiles[mapHeader.mapSize.height - 1 - y][x]
				if let tile = tile as? BlockData.BlockStructure
				{
					let bgTile = StaticTile(index: tile.backgroundIndex)
					workTileLayers[0].setTileAtX(x, y: y, tile: bgTile)

					for i in 0..<3
					{
						if tile.foregroundIndices[i] != 0
						{
							let fgTile = StaticTile(index: tile.foregroundIndices[i])
							workTileLayers[i + 1].setTileAtX(x, y: y, tile: fgTile)
						}
					}
				}
				else if let _ = tile as? AnimationData.AnimationStructure
				{
					// TODO
				}
				else
				{
					assertionFailure()
				}
			}
		}

		guard let bgLayer = workTileLayers[0].tileLayer else { return nil }
		var tileLayers = [bgLayer]

		for workLayer in workTileLayers.dropFirst()
		{
			if let fgLayer = workLayer.tileLayer where workLayer.used
			{
				tileLayers.append(fgLayer)
			}
		}

		return tileLayers
	}
}

extension Map
{
	convenience init?(tileMap: TileMap) throws
	{
		self.init()

		guard let blockSize = tileMap.blockSize() else
		{
			return nil
		}
		let textures = try tileMap.textures()
		guard let atlasImage = textureAtlasWithBlockSize(blockSize, textures: textures) else
		{
			return nil
		}
		let tileSet = TileSet(image: atlasImage,
			imageName:  "tilemap.tiff",
			name: "Imported from TileMap",
			tileCount: textures.count,
			tileWidth: blockSize.width,
			tileHeight: blockSize.height)

		self.addTileSet(tileSet)

		var zIndex = 0
		for layer in tileMap.layers
		{
			let baseLayerName = layer.chunkType.rawValue.rawValue
			if let tileLayers = tileMap.tileLayersForLayer(layer, tileSet: tileSet)
			{
				for (i, tileLayer) in tileLayers.enumerate()
				{
					let layerName = baseLayerName + "_" + String(i)
					tileLayer.name = layerName
					tileLayer.zIndex = zIndex
					zIndex = zIndex + 1
					self.addTileLayer(tileLayer)
				}
			}
		}

	}
}
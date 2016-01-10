//
//  Layer.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/9/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

public protocol Tileable {}

public class Layer : Loadable
{
	public private(set) var chunkType : ChunkType
	public let tiles : [[Tileable]]

	required public init?(inputStream: NSInputStream, dataLength: Int, tileMap: TileMap, chunkType: ChunkType)
	{
		self.chunkType = chunkType
		
		guard let mapHeader = tileMap.mapHeader,
		let blockData = tileMap.blockData,
		let animationData = tileMap.animationData else
		{
			tiles = [[Tileable]]()
			return nil
		}
		let swapBytes = mapHeader.swapBytes

		var tileRows = [[Tileable]]()
		if mapHeader.mapType == .FMP05
		{
			for _ in 0..<mapHeader.mapSize.height
			{
				var tileColumns = [Tileable]()
				for _ in 0..<mapHeader.mapSize.width
				{
					guard let tile = inputStream.readInt16(swapBytes) else
					{
						tiles = [[Tileable]]()
						return nil
					}

					if tile >= 0
					{
						let theIndex = Int(tile) / mapHeader.blockStructureSize
						tileColumns.append(blockData.blockStructures[theIndex])
					}
					else
					{
						let divisor : Int
						if .FMP05 == mapHeader.mapType
						{
							divisor = 16
						}
						else
						{
							divisor = 1
						}
						let theIndex = Int(-tile) / divisor - 1
						tileColumns.append(animationData.animationStructures[theIndex])
					}
				}
				tileRows.append(tileColumns)
			}
		}
		else if mapHeader.mapType == .FMP10
		{
			// TODO
			assert(false, "FMP 1.0 Maps not yet implemented")
		}
		else if mapHeader.mapType == .FMP10RLE
		{
			// TODO
			assert(false, "FMP 1.0RLE Maps not yet implemented")
		}
		else
		{
			// TODO Throw too new (shouldn't even get here in that case)
			tiles = [[Tileable]]()
			return nil
		}

		tiles = tileRows

		tileMap.addLayer(self, index: chunkType.layer())
	}

	static func registerWithTileMap(tileMap: TileMap)
	{
		tileMap.registerLoadable(self, chunkType: ChunkType.BODY)
		tileMap.registerLoadable(self, chunkType: ChunkType.LYR1)
		tileMap.registerLoadable(self, chunkType: ChunkType.LYR2)
		tileMap.registerLoadable(self, chunkType: ChunkType.LYR3)
		tileMap.registerLoadable(self, chunkType: ChunkType.LYR4)
		tileMap.registerLoadable(self, chunkType: ChunkType.LYR5)
		tileMap.registerLoadable(self, chunkType: ChunkType.LYR6)
		tileMap.registerLoadable(self, chunkType: ChunkType.LYR7)
	}
}

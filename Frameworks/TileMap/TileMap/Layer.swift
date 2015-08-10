//
//  Layer.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/9/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

protocol Tileable
{

}

class Layer : Loadable
{
	var chunkType : ChunkType?
	let tiles : [[Tileable]]

	required init?(inputStream: NSInputStream, dataLength: Int, tileMap: TileMap, chunkType: ChunkType)
	{
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

					let tileIndex = Int(tile) / mapHeader.blockStructureSize
					if tile >= 0
					{
						tileColumns.append(blockData.blockStructures[tileIndex])
					}
					else
					{
						tileColumns.append(animationData.animationStructures[-tileIndex])
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

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

	required init?(inputStream: NSInputStream, dataLength: Int, tileMap: TileMap)
	{
		guard let mapHeader = tileMap.mapHeader else
		{
			tiles = [[Tileable]]()
			return nil
		}
		let swapBytes = mapHeader.swapBytes

		chunkType = nil
		var bytes = [UInt8](count: dataLength, repeatedValue: 0)
		guard inputStream.read(&bytes, maxLength: dataLength) == dataLength else
		{
			tiles = [[Tileable]]()
			return nil
		}

		if mapHeader.mapType == .FMP05
		{
			for _ in 0..<mapHeader.mapSize.height
			{
				for _ in 0..<mapHeader.mapSize.width
				{
					guard let tile = inputStream.readInt16(swapBytes) else
					{
						tiles = [[Tileable]]()
						return nil
					}
/*
					*mymappt = (short int) MapGetshort (mdatpt);
					if (*mymappt >= 0) { *mymappt /= blockstrsize; }
					else { *mymappt /= 16; *mymappt *= sizeof(ANISTR); }
					mdatpt+=2; mymappt++;
*/
				}
			}
		}
		else if mapHeader.mapType == .FMP10
		{
			// TODO
		}
		else if mapHeader.mapType == .FMP10RLE
		{
			// TODO
		}
		else
		{
			// TODO Throw too new (shouldn't even get here in that case)
			tiles = [[Tileable]]()
			return nil
		}

		tiles = [[Tileable]]()
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

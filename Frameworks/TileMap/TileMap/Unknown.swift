//
//  Unknown.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/9/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

class Unknown : Loadable
{
	required init?(inputStream: NSInputStream, dataLength: Int, tileMap: TileMap, chunkType: ChunkType)
	{
		var bytes = [UInt8](count: dataLength, repeatedValue: 0)
		guard inputStream.read(&bytes, maxLength: dataLength) == dataLength else
		{
			return nil
		}

		tileMap.addUnknownChunk(self)
	}

	static func registerWithTileMap(tileMap: TileMap)
	{
		// Do nothing
	}
}

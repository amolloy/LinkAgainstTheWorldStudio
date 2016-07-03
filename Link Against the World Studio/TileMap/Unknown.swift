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
	required init?(inputStream: InputStream, dataLength: Int, tileMap: TileMap, chunkType: ChunkType)
	{
		var bytes = [UInt8](repeating: 0, count: dataLength)
		guard inputStream.read(&bytes, maxLength: dataLength) == dataLength else
		{
			return nil
		}

		tileMap.addUnknownChunk(self)
	}

	static func registerWithTileMap(_ tileMap: TileMap)
	{
		// Do nothing
	}
}

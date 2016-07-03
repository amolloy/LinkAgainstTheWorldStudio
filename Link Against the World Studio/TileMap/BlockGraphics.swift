//
//  BlockGraphics.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/9/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

public class BlockGraphics : Loadable
{
	let buffer : [UInt8]

	required public init?(inputStream: InputStream, dataLength: Int, tileMap: TileMap, chunkType: ChunkType)
	{
		var bytes = [UInt8](repeating: 0, count: dataLength)
		guard inputStream.read(&bytes, maxLength: dataLength) == dataLength else
		{
			buffer = [UInt8]()
			return nil
		}
		buffer = bytes

		tileMap.blockGraphics = self
	}

	static func registerWithTileMap(_ tileMap: TileMap)
	{
		tileMap.registerLoadable(self, chunkType: ChunkType.bgfx)
	}
}

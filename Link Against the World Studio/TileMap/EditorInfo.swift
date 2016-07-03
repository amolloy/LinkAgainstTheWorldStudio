//
//  EditorInfoChunk.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/3/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

// The EditorInfoChunk stores editor information such as the last offset
// into the map the user was editing, what size the editing screen was, 
// etc. We'll just ignore it since we won't be using it even in our editor.
public class EditorInfo : Loadable
{
	required public init?(inputStream: InputStream, dataLength: Int, tileMap: TileMap, chunkType: ChunkType)
	{
		var bytes = [UInt8](repeating: 0, count: dataLength)
		guard inputStream.read(&bytes, maxLength: dataLength) == dataLength else
		{
			return nil
		}

		tileMap.editorInfo = self
	}

	static func registerWithTileMap(_ tileMap: TileMap)
	{
		tileMap.registerLoadable(self, chunkType: ChunkType.edhd)
	}
}

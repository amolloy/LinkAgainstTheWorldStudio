//
//  MapAuthor.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/30/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

public class Author : Loadable
{
	let authorInfo : [String]

	required public init?(inputStream: NSInputStream, dataLength: Int, tileMap: TileMap, chunkType: ChunkType)
	{
		// ATHR chunk is up to 4 NULL-separated C-strings
		var bytes = [UInt8](count: dataLength, repeatedValue: 0)
		guard inputStream.read(&bytes, maxLength: dataLength) == dataLength else
		{
			self.authorInfo = [String]()
			return nil
		}

		var currentAuthorInfo = ""
		var authorInfo = [String]()

		for c in bytes
		{
			if c != 0
			{
				currentAuthorInfo.append(UnicodeScalar(c))
			}
			else
			{
				authorInfo.append(currentAuthorInfo)
				currentAuthorInfo = ""
			}
		}

		self.authorInfo = authorInfo

		tileMap.author = self
	}

	static func registerWithTileMap(tileMap: TileMap)
	{
		tileMap.registerLoadable(self, chunkType: ChunkType.ATHR)
	}
}

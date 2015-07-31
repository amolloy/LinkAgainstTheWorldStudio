//
//  MapAuthor.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/30/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

@objc
class Author : NSObject, Chunk
{
	let authorInfo : [String]

	static func fourCC() -> String
	{
		return "ATHR";
	}

	required init(chunkData : NSData)
	{
		// ATHR chunk is up to 4 NULL-separated C-strings

		var bytes = [UInt8](count: chunkData.length, repeatedValue: 0)
		chunkData.getBytes(&bytes, length:chunkData.length)

		var authorInfo = [String]()
		var currentAuthorInfo = ""

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
	}
}

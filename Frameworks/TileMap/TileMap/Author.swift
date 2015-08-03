//
//  MapAuthor.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/30/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

class Author : Chunk
{
	let authorInfo : [String]

	required init?(inputStream: NSInputStream, length: Int)
	{
		// ATHR chunk is up to 4 NULL-separated C-strings
		var bytes = [UInt8](count: length, repeatedValue: 0)
		guard inputStream.read(&bytes, maxLength: length) == length else
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
	}

	func description() -> String
	{
		return "ATHR: \(authorInfo)"
	}
}

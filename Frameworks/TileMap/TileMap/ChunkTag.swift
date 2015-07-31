//
//  ChunkTag.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/31/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

// Represents a FourCC chunk tag
struct ChunkTag : Equatable
{
	var tag : [Char]

	init?(characters: [Char])
	{
		guard characters.count == 4 else { return nil }
		tag = characters
	}

	init?(fourCCString : String)
	{
		let fourCCStringUTF8 = fourCCString.utf8
		var chars = [Char]()
		for char in fourCCStringUTF8
		{
			let charValue = UInt8(char.value)
			if let char = Char(rawValue: charValue)
			{
				chars.append(char)
			}
		}
		guard chars.count == 4 else { return nil }

		tag = [Char](chars)
	}
}

func ==(lhs: ChunkTag, rhs: ChunkTag) -> Bool
{
	return lhs.tag == rhs.tag
}

extension NSInputStream
{
	func readChunkTag() -> ChunkTag?
	{
		var formTag = [Char](count: 4, repeatedValue: Char.NULL)
		if read(&formTag, maxLength: 4) == 4
		{
			return ChunkTag(characters: formTag)
		}

		return nil
	}
}


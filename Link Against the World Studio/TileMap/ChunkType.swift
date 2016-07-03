//
//  ChunkType.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/9/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

public enum ChunkType : ChunkTag
{
	case athr = "ATHR"
	case mphd = "MPHD"
	case edhd = "EDHD"
	case cmap = "CMAP"
	case bkdt = "BKDT"
	case andt = "ANDT"
	case bgfx = "BGFX"

	case body = "BODY"
	case lyr1 = "LYR1"
	case lyr2 = "LYR2"
	case lyr3 = "LYR3"
	case lyr4 = "LYR4"
	case lyr5 = "LYR5"
	case lyr6 = "LYR6"
	case lyr7 = "LYR7"

	public func layer() -> Int
	{
		let layer : Int
		switch(self)
		{
		case body:
			layer = 0
			break
		case lyr1:
			layer = 1
			break
		case lyr2:
			layer = 2
			break
		case lyr3:
			layer = 3
			break
		case lyr4:
			layer = 4
			break
		case lyr5:
			layer = 5
			break
		case lyr6:
			layer = 6
			break
		case lyr7:
			layer = 7
			break
		default:
			layer = -1
			break
		}
		return layer
	}
}

public func ~=(pattern: String, value: ChunkType) -> Bool
{
	let match = value.rawValue.rawValue.range(of: pattern, options: .regularExpressionSearch)
	return match != nil
}

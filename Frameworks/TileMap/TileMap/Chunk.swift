//
//  Chunk.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/30/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

enum ChunkType : ChunkTag
{
	case ATHR = "ATHR"
	case MPHD = "MPHD"
	case EDHD = "EDHD"
	case CMAP = "CMAP"
	case BKDT = "BKDT"
	case ANDT = "ANDT"
	case BGFX = "BGFX"
	case BODY = "BODY"
	case LYR = "LYR?"
}

protocol Chunk
{

	static func fourCC() -> String

	init(chunkData : NSData)
}

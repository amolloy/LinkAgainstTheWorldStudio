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

	case LYR1 = "LYR1"
	case LYR2 = "LYR2"
	case LYR3 = "LYR3"
	case LYR4 = "LYR4"
	case LYR5 = "LYR5"
	case LYR6 = "LYR6"
	case LYR7 = "LYR7"
}

enum ChunkError : ErrorType
{
	case InvalidChunkTag
	case MissingMapHeader
}

protocol Chunk
{
	func description() -> String
}

func loadChunk(inputStream: NSInputStream, mapHeader: MapHeader?) throws -> Chunk?
{
	guard let chunkTag = inputStream.readChunkTag() else
	{
		return nil
	}

	guard let chunkType = ChunkType(rawValue: chunkTag) else
	{
		return nil
	}

	guard let chunkLength = inputStream.readBigInt() else
	{
		return nil
	}

	switch (chunkType)
	{
	case ChunkType.ATHR:
		return Author(inputStream: inputStream, length: chunkLength)
	case ChunkType.MPHD:
		return MapHeader(inputStream: inputStream, length: chunkLength)
	case ChunkType.EDHD:
		return EditorInfoChunk(inputStream: inputStream, length: chunkLength)
	case ChunkType.CMAP:
		return ColorMap(inputStream: inputStream, length: chunkLength)
	case ChunkType.BKDT:
		guard let mapHeader = mapHeader else
		{
			throw ChunkError.MissingMapHeader
		}
		return BlockData(inputStream: inputStream, length: chunkLength, mapHeader: mapHeader)
	case ChunkType.ANDT:
		guard let mapHeader = mapHeader else
		{
			throw ChunkError.MissingMapHeader
		}
		return AnimationData(inputStream: inputStream, length: chunkLength, mapHeader: mapHeader)
	default:
		print("Unknown chunk tag: \(chunkType)")
		var buffer = [UInt8](count: chunkLength, repeatedValue: 0)
		inputStream.read(&buffer, maxLength: chunkLength)
		return nil
	}
}


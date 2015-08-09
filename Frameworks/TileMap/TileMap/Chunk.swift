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

	func layer() -> Int
	{
		let layer : Int
		switch(self)
		{
		case BODY:
			layer = 0
			break
		case LYR1:
			layer = 1
			break
		case LYR2:
			layer = 2
			break
		case LYR3:
			layer = 3
			break
		case LYR4:
			layer = 4
			break
		case LYR5:
			layer = 5
			break
		case LYR6:
			layer = 6
			break
		case LYR7:
			layer = 7
			break
		default:
			layer = -1
			break
		}
		return layer
	}
}

func ~=(pattern: String, value: ChunkType) -> Bool
{
	let match = value.rawValue.rawValue.rangeOfString(pattern, options: .RegularExpressionSearch)
	return match != nil
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
	case .ATHR:
		return Author(inputStream: inputStream, length: chunkLength)
	case .MPHD:
		return MapHeader(inputStream: inputStream, length: chunkLength)
	case .EDHD:
		return EditorInfoChunk(inputStream: inputStream, length: chunkLength)
	case .CMAP:
		return ColorMap(inputStream: inputStream, length: chunkLength)
	case .BKDT:
		guard let mapHeader = mapHeader else
		{
			throw ChunkError.MissingMapHeader
		}
		return BlockData(inputStream: inputStream, length: chunkLength, mapHeader: mapHeader)
	case .ANDT:
		guard let mapHeader = mapHeader else
		{
			throw ChunkError.MissingMapHeader
		}
		return AnimationData(inputStream: inputStream, length: chunkLength, mapHeader: mapHeader)
	case .BGFX:
		return BlockGraphics(inputStream: inputStream, length: chunkLength)
	case .BODY, "LYR[0-7]":
		guard let mapHeader = mapHeader else
		{
			throw ChunkError.MissingMapHeader
		}
		return Layer(inputStream: inputStream,
			length: chunkLength,
			mapHeader: mapHeader,
			chunkType: chunkType)
	default:
		print("Unknown chunk tag: \(chunkType)")
		var buffer = [UInt8](count: chunkLength, repeatedValue: 0)
		inputStream.read(&buffer, maxLength: chunkLength)
		return nil
	}
}


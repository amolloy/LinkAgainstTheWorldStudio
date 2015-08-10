//
//  TileMapLoader.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/9/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

extension TileMap
{
	enum TileMapFileError : ErrorType
	{
		case InvalidHeaderError
	}

	func open() throws -> Bool
	{
		inputStream.open()
		try loadFileHeader(inputStream)

		return true
	}

	func loadChunks() throws
	{
		try loadChunks(inputStream)
	}

	private func loadFileHeader(inputStream : NSInputStream) throws
	{
		guard let formTag = inputStream.readChunkTag() else
		{
			throw TileMapFileError.InvalidHeaderError
		}

		if (formTag != "FORM")
		{
			throw TileMapFileError.InvalidHeaderError
		}

		// Skip past the data length
		guard let _ = inputStream.readBigInt() else
		{
			throw TileMapFileError.InvalidHeaderError
		}

		guard let fmapTag = inputStream.readChunkTag() else
		{
			throw TileMapFileError.InvalidHeaderError
		}

		if (fmapTag != "FMAP")
		{
			throw TileMapFileError.InvalidHeaderError
		}
	}

	private func loadChunks(inputStream : NSInputStream) throws
	{
		while let chunk = try loadChunk(inputStream)
		{
			print("Loaded chunk type \(chunk)")
		}
	}

	private func loadChunk(inputStream: NSInputStream) throws -> Loadable?
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

		let chunk : Loadable?
		if let loader = loaders[chunkType]
		{
			chunk = loader.init(inputStream: inputStream,
				dataLength: chunkLength,
				tileMap: self,
				chunkType: chunkType)
		}
		else
		{
			chunk = Unknown(inputStream: inputStream,
				dataLength: chunkLength,
				tileMap: self,
				chunkType: chunkType)
		}
		return chunk
	}

	func addLayer(layer: Layer, index: Int)
	{
		assert(index == layers.count, "Layers must appear in the file in order")
		layers.append(layer)
	}

	func addUnknownChunk(chunk: Unknown)
	{
		unknownChunks.append(chunk)
	}
}

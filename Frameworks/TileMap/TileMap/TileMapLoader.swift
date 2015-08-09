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
		var layers = [Layer]()
		var unknownChunks = [Unknown]()

		while let chunk = try loadChunk(inputStream)
		{
			if let author = chunk as? Author
			{
				self.author = author
			}
			else if let blockData = chunk as? BlockData
			{
				self.blockData = blockData
			}
			else if let colorMap = chunk as? ColorMap
			{
				self.colorMap = colorMap
			}
			else if let editorInfo = chunk as? EditorInfo
			{
				self.editorInfo = editorInfo
			}
			else if let layer = chunk as? Layer
			{
				// TODO make sure they are in order
				layers.append(layer)
			}
			else if let mapHeader = chunk as? MapHeader
			{
				self.mapHeader = mapHeader
			}
			else if let unknownChunk = chunk as? Unknown
			{
				unknownChunks.append(unknownChunk)
			}

			print("Loaded chunk type \(chunk)")
		}

		self.layers = layers
		self.unknownChunks = unknownChunks
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
			chunk = loader.init(inputStream: inputStream, dataLength: chunkLength, tileMap: self)
		}
		else
		{
			chunk = Unknown(inputStream: inputStream, dataLength: chunkLength, tileMap: self)
		}
		return chunk
	}
}

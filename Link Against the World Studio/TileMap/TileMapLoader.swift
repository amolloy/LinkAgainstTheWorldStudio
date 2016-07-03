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
	enum Error : ErrorProtocol
	{
		case invalidHeaderError
	}

	public func open() throws -> Bool
	{
		inputStream.open()
		try loadFileHeader(inputStream)

		return true
	}

	public func loadChunks() throws
	{
		try loadChunks(inputStream)
	}

	private func loadFileHeader(_ inputStream : InputStream) throws
	{
		guard let formTag = inputStream.readChunkTag() else
		{
			throw Error.invalidHeaderError
		}

		if (formTag != "FORM")
		{
			throw Error.invalidHeaderError
		}

		// Skip past the data length
		guard let _ = inputStream.readBigInt() else
		{
			throw Error.invalidHeaderError
		}

		guard let fmapTag = inputStream.readChunkTag() else
		{
			throw Error.invalidHeaderError
		}

		if (fmapTag != "FMAP")
		{
			throw Error.invalidHeaderError
		}
	}

	private func loadChunks(_ inputStream : InputStream) throws
	{
		while let chunk = try loadChunk(inputStream)
		{
			print("Loaded chunk type \(chunk)")
		}
	}

	private func loadChunk(_ inputStream: InputStream) throws -> Loadable?
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

	func addLayer(_ layer: Layer, index: Int)
	{
		assert(index == layers.count, "Layers must appear in the file in order")
		layers.append(layer)
	}

	func addUnknownChunk(_ chunk: Unknown)
	{
		unknownChunks.append(chunk)
	}
}

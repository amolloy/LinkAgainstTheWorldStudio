//
//  TileMapFile.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/31/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

class TileMapFile
{
	enum TileMapFileError : ErrorType
	{
		case InvalidHeaderError
	}

	let filePath : String
	let inputStream : NSInputStream
	private(set) var dataLength : Int
	private(set) var chunks : [Chunk]

	init?(path : String)
	{
		filePath = path
		dataLength = 0
		chunks = []
		let ins = NSInputStream(fileAtPath: filePath)
		if let ins = ins
		{
			inputStream = ins
		}
		else
		{
			inputStream = NSInputStream()
			return nil
		}
	}

	func open() throws -> Bool
	{
		inputStream.open()
		try loadFileHeader(inputStream)

		return true
	}

	func loadChunks() throws -> Bool
	{
		try loadChunks(inputStream)

		return chunks.count != 0
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

		if let length = inputStream.readBigInt()
		{
			dataLength = length
		}
		else
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
		var chunks = [Chunk]()
		var mapHeader : MapHeader? = nil

		while let chunk = try loadChunk(inputStream, mapHeader: mapHeader)
		{
			if let mh = chunk as? MapHeader
			{
				mapHeader = mh
			}

			print("Loaded chunk type \(chunk): \(chunk.description())")
			chunks.append(chunk)
		}
	}
}


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
	private(set) var dataLength : Int
	private(set) var chunks : [Chunk]

	init(path : String)
	{
		filePath = path
		hasFORMTag = false
		hasFMAPTag = false
		dataLength = 0
		chunks = []
	}

	func load() throws -> Bool
	{
		guard let inputStream = NSInputStream(fileAtPath: filePath) else { return false }

		inputStream.open()

		try loadFileHeader(inputStream)

		return true
	}

	private (set) var hasFORMTag : Bool
	private (set) var hasFMAPTag : Bool
	private func loadFileHeader(inputStream : NSInputStream) throws
	{
		guard let formTag = inputStream.readChunkTag() else
		{
			throw TileMapFileError.InvalidHeaderError
		}

		hasFORMTag = formTag == "FORM"
		if (!hasFORMTag)
		{
			throw TileMapFileError.InvalidHeaderError
		}

		if !inputStream.readBigInt(&dataLength)
		{
			throw TileMapFileError.InvalidHeaderError
		}

		guard let fmapTag = inputStream.readChunkTag() else
		{
			throw TileMapFileError.InvalidHeaderError
		}
		hasFMAPTag = fmapTag == "FMAP"

		if (!hasFMAPTag)
		{
			throw TileMapFileError.InvalidHeaderError
		}
	}

	func loadChunks(inputStream : NSInputStream) throws
	{
		
	}
}


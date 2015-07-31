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

	init(path : String)
	{
		filePath = path
		hasFORMTag = false
		hasFMAPTag = false
		dataLength = 0
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
		var formTag = [Char](count: 4, repeatedValue: Char.NULL)
		if inputStream.read(&formTag, maxLength: 4) != 4
		{
			throw TileMapFileError.InvalidHeaderError
		}

		switch (formTag[0], formTag[1], formTag[2], formTag[3])
		{
		case (Char.F, Char.O, Char.R, Char.M):
			hasFORMTag = true
			break
		default :
			throw TileMapFileError.InvalidHeaderError
		}

		if !inputStream.readBigInt(&dataLength)
		{
			throw TileMapFileError.InvalidHeaderError
		}

		var fmapTag = [Char](count: 4, repeatedValue: Char.NULL)
		if inputStream.read(&fmapTag, maxLength: 4) != 4
		{
			throw TileMapFileError.InvalidHeaderError
		}

		switch (fmapTag[0], fmapTag[1], fmapTag[2], fmapTag[3])
		{
		case (Char.F, Char.M, Char.A, Char.P):
			hasFMAPTag = true
			break
		default :
			throw TileMapFileError.InvalidHeaderError
		}
	}
}


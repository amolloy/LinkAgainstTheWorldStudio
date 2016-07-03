//
//  ColorMapChunk.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/5/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

public class ColorMap : Loadable
{
	let palette : [TileMap.Color]

	required public init?(inputStream: InputStream, dataLength: Int, tileMap: TileMap, chunkType: ChunkType)
	{
		if dataLength % 3 != 0
		{
			palette = []
			return nil
		}

		var p : [TileMap.Color] = []
		let numColors = dataLength / 3

		for _ in 0..<numColors
		{
			guard let red = inputStream.readUInt8(),
			let green = inputStream.readUInt8(),
			let blue = inputStream.readUInt8() else
			{
				palette = []
				return nil
			}

			p.append(r: red, g: green, b: blue)
		}

		palette = p

		tileMap.colorMap = self
	}

	static func registerWithTileMap(_ tileMap: TileMap)
	{
		tileMap.registerLoadable(self, chunkType: ChunkType.cmap)
	}
}

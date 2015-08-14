//
//  TileMap.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/9/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

public class TileMap
{
	typealias Color = (r: UInt8, g: UInt8, b: UInt8)

	var inputStream : NSInputStream

	var animationData : AnimationData?
	var author : Author?
	var blockData : BlockData?
	var blockGraphics : BlockGraphics?
	var colorMap : ColorMap?
	var editorInfo : EditorInfo?
	var layers : [Layer]
	var mapHeader : MapHeader?
	var unknownChunks : [Unknown]

	public init?(path : String)
	{
		loaders = [ChunkType: Loadable.Type]()

		animationData = nil
		author = nil
		blockData = nil
		blockGraphics = nil
		colorMap = nil
		editorInfo = nil
		layers = [Layer]()
		mapHeader = nil
		unknownChunks = [Unknown]()

		guard let inputStream = NSInputStream(fileAtPath: path) else
		{
			self.inputStream = NSInputStream()
			return nil
		}
		self.inputStream = inputStream

		let loadableTypes : [Loadable.Type] = [
			AnimationData.self,
			Author.self,
			BlockData.self,
			BlockGraphics.self,
			ColorMap.self,
			EditorInfo.self,
			Layer.self,
			MapHeader.self,
			Unknown.self]
		loadableTypes.forEach() {
			$0.registerWithTileMap(self)
		}
	}

	var loaders : [ChunkType: Loadable.Type]
	func registerLoadable(loadable: Loadable.Type, chunkType: ChunkType)
	{
		loaders[chunkType] = loadable
	}
}

func == (c1:TileMap.Color, c2:TileMap.Color) -> Bool
{
	return (c1.r == c2.r) && (c1.g == c2.g) && (c1.b == c2.b)
}

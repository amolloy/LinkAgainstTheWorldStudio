//
//  TileMap.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/9/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

class TileMap
{
	var inputStream : NSInputStream

	var author : Author!
	var blockData : BlockData!
	var animationData : AnimationData!
	var colorMap : ColorMap!
	var editorInfo : EditorInfo!
	var layers : [Layer]
	var mapHeader : MapHeader?
	var unknownChunks : [Unknown]

	init?(path : String)
	{
		loaders = [ChunkType: Loadable.Type]()

		author = nil
		blockData = nil
		animationData = nil
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
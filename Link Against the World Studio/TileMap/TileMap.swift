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

	public struct Size
	{
		public let width : Int
		public let height : Int
		public init(_ width: Int, _ height: Int)
		{
			self.width = width
			self.height = height
		}
		public init(_ width: Int16, _ height: Int16)
		{
			self.init(Int(width), Int(height))
		}
		public init()
		{
			self.init(0, 0)
		}
	}

	var inputStream : NSInputStream

	public internal(set) var animationData : AnimationData?
	public internal(set) var author : Author?
	public internal(set) var blockData : BlockData?
	public internal(set) var blockGraphics : BlockGraphics?
	public internal(set) var colorMap : ColorMap?
	public internal(set) var editorInfo : EditorInfo?
	public internal(set) var layers : [Layer]
	public internal(set) var mapHeader : MapHeader?
	var unknownChunks : [Unknown]

	public convenience init?(path : String)
	{
		guard let inputStream = NSInputStream(fileAtPath: path) else
		{
			return nil
		}

		self.init(inputStream: inputStream)
	}

	public init?(inputStream : NSInputStream)
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

	public func blockSize() -> Size?
	{
		guard let mapHeader = self.mapHeader else
		{
			return nil
		}
		return mapHeader.blockSize
	}
}

func == (c1:TileMap.Color, c2:TileMap.Color) -> Bool
{
	return (c1.r == c2.r) && (c1.g == c2.g) && (c1.b == c2.b)
}

public extension NSSize
{
	public init(_ size: TileMap.Size)
	{
		width = CGFloat(size.width)
		height = CGFloat(size.height)
	}
}

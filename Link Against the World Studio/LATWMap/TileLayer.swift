//
//  TileLayer.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/5/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation

public protocol Tileable
{
	// UGH Because of protocol extension dispatch rules, this MUST be here and cannot be in the EditorMap framework where it belongs.
	func editorMapRepresentation() -> String
}

final public class TileLayer
{
	public private(set) var tiles: [[Tileable]]
	public var name: String
	public private(set) var tileSet : TileSet?
	public var zIndex: Int

	public struct Coordinate
	{
		public let x : Int
		public let y : Int

		public init(x: Int, y: Int)
		{
			self.x = x
			self.y = y
		}
	}

	public init()
	{
		self.name = ""
		self.tiles = [[Tileable]]()
		self.zIndex = 0
	}

	public init(name: String, tiles: [[Tileable]], tileSet: TileSet)
	{
		self.name = name
		self.tiles = tiles
		self.zIndex = 0
		self.tileSet = tileSet
	}

	public func setTileAt(_ coordinate: Coordinate, tile: Tileable)
	{
		tiles[coordinate.y][coordinate.x] = tile
	}

	public struct Size
	{
		public let width : Int
		public let height : Int
	}

	public var size : Size
	{
		get
		{
			return Size(width: tiles[0].count, height: tiles.count)
		}
	}
}

public class EmptyTile : Tileable
{
	public init() {}
	public func editorMapRepresentation() -> String
	{
		return "-"
	}
}

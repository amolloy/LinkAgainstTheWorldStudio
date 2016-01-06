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

	public init()
	{
		self.name = ""
		self.tiles = [[Tileable]]()
		self.zIndex = 0
	}

	public init(name: String, tiles: [[Tileable]])
	{
		self.name = name
		self.tiles = tiles
		self.zIndex = 0
	}

	public func setTileAtX(x: Int, y: Int, tile: Tileable)
	{
		tiles[y][x] = tile
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

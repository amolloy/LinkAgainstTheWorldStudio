//
//  TileLayer.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/5/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation

public protocol Tileable {}

public class TileLayer
{
	public private(set) var tiles: [[Tileable]]
	public var name: String
	public private(set) var tileSet : TileSet?

	public init()
	{
		self.name = ""
		self.tiles = [[Tileable]]()
	}

	public init(name: String, tiles: [[Tileable]])
	{
		self.name = name
		self.tiles = tiles
	}

	public func setTileAtX(x: Int, y: Int, tile: Tileable)
	{
		tiles[y][x] = tile
	}
}

public class EmptyTile : Tileable
{
	public init() {}
}

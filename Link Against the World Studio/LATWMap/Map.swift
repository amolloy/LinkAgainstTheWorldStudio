//
//  Map.swift
//  LATWMap
//
//  Created by Andrew Molloy on 1/2/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Cocoa

public class Map
{
	public private(set) var tileSets : [String: TileSet]
	public private(set) var tileLayers : [TileLayer]

	public init()
	{
		self.tileSets = [String: TileSet]()
		self.tileLayers = [TileLayer]()
	}
}

private typealias MapTileSets = Map
extension MapTileSets
{
	public func addTileSet(_ tileSet: TileSet) -> Bool
	{
		if let _ = tileSets[tileSet.name]
		{
			return false
		}
		tileSets[tileSet.name] = tileSet
		return true
	}
}

private typealias MapTileLayers = Map
extension MapTileLayers
{
	public func addTileLayer(_ tileLayer: TileLayer)
	{
		tileLayers.append(tileLayer)
	}
}

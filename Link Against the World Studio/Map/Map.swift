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

	public init()
	{
		self.tileSets = [String: TileSet]()
	}

	public func addTileSet(tileSet: TileSet) -> Bool
	{
		if let _ = tileSets[tileSet.name]
		{
			return false
		}
		tileSets[tileSet.name] = tileSet
		return true
	}
}

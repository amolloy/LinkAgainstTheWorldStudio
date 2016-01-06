//
//  StaticTile.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/5/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation

public class StaticTile : Tileable
{
	unowned var tileSet : TileSet
	var index : Int

	public init(tileSet: TileSet, index: Int)
	{
		self.tileSet = tileSet
		self.index = index
	}
}

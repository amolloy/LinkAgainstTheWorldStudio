//
//  TileSet.swift
//  LATWMap
//
//  Created by Andrew Molloy on 1/2/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation
import CrossPlatform

public class TileSet
{
	let image : Image
	let name : String
	let tileCount : Int
	let tileWidth : Int
	let tileHeight :Int

	public init(image: Image, name: String, tileCount: Int, tileWidth: Int, tileHeight: Int)
	{
		self.image = image
		self.name = name
		self.tileCount = tileCount
		self.tileWidth = tileWidth
		self.tileHeight = tileHeight
	}
}

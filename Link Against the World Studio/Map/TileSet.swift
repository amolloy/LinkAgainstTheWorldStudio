//
//  TileSet.swift
//  LATWMap
//
//  Created by Andrew Molloy on 1/2/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation

class TileSet
{
	let image : Image
	let name : String
	let tileCount : Int
	let width : Int
	let height :Int

	init(image: Image, name: String, tileCount: Int, width: Int, height: Int)
	{
		self.image = image
		self.name = name
		self.tileCount = tileCount
		self.width = width
		self.height = height
	}
}

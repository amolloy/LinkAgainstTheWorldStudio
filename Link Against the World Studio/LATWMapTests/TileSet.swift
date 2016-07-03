//
//  TileSet.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/2/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import XCTest
@testable import LATWMap
import CrossPlatform

class TileSetTests: XCTestCase
{
	func testInit()
	{
		let image = CrossPlatform.Image()
		let tileset = TileSet(image: image, imageName: "image", name: "name", tileCount: 16, tileWidth: 8, tileHeight: 8)

		XCTAssertEqual(tileset.image, image)
		XCTAssertEqual(tileset.imageName, "image")
		XCTAssertEqual(tileset.name, "name")
		XCTAssertEqual(tileset.tileCount, 16)
		XCTAssertEqual(tileset.tileWidth, 8)
		XCTAssertEqual(tileset.tileHeight, 8)
	}
}

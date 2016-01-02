//
//  TileSet.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/2/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import XCTest
@testable import Map

class TileSetTests: XCTestCase
{
	func testInit()
	{
		let image = Image()
		let tileset = TileSet(image: image, name: "name", tileCount: 16, width: 8, height: 8)

		XCTAssertEqual(tileset.image, image)
		XCTAssertEqual(tileset.name, "name")
		XCTAssertEqual(tileset.tileCount, 16)
		XCTAssertEqual(tileset.width, 8)
		XCTAssertEqual(tileset.height, 8)
	}
}

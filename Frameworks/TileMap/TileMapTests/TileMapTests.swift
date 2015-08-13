//
//  TileMapTests.swift
//  TileMapTests
//
//  Created by Andrew Molloy on 7/30/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import XCTest
@testable import TileMap

class TileMapTests: XCTestCase
{
	var testMapPath : String
	{
		get
		{
			let bundle = NSBundle(forClass: TileMapTests.self)
			let testMapPath = bundle.pathForResource("Test", ofType: "fmp")
			return testMapPath ?? ""
		}
	}

	func testLoadHeader()
	{
		guard let tileMapFile = TileMap(path: testMapPath) else
		{
			XCTFail()
			return
		}
		do
		{
			try tileMapFile.open()
		}
		catch let e
		{
			XCTFail("tileMapFile.load() threw \(e)")
		}
	}

	func testLoadChunks()
	{
		guard let tileMapFile = TileMap(path: testMapPath) else
		{
			XCTFail()
			return
		}
		do
		{
			try tileMapFile.open()
		}
		catch let e
		{
			XCTFail("tileMapFile.open() threw \(e)")
		}
		do
		{
			try tileMapFile.loadChunks()
		}
		catch let e
		{
			XCTFail("tileMapFile.loadChunks() threw \(e)")
		}

		XCTAssertNotNil(tileMapFile.animationData)
		XCTAssertNotNil(tileMapFile.author)
		XCTAssertNotNil(tileMapFile.blockData)
		XCTAssertNotNil(tileMapFile.blockGraphics)
		XCTAssertNotNil(tileMapFile.colorMap)
		XCTAssertNotNil(tileMapFile.editorInfo)
		XCTAssertNotNil(tileMapFile.mapHeader)
		XCTAssertNotEqual(tileMapFile.layers.count, 0)
	}
}

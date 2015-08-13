//
//  TileMapSKRenderer.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/13/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import XCTest
@testable import TileMap

class TileMapSKRendererTests: XCTestCase
{
	lazy var tileMap : TileMap? =
	{
		let bundle = NSBundle(forClass: TileMapTests.self)
		guard let testMapPath = bundle.pathForResource("Test", ofType: "fmp") else
		{
			XCTFail()
			return nil
		}

		guard let tileMapFile = TileMap(path: testMapPath) else
		{
			XCTFail()
			return nil
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
		return tileMapFile
	}()

	func testLoadAtlas()
	{
		guard let tileMap = self.tileMap else
		{
			XCTFail("Could not load TileMap for testing")
			return
		}

		let renderer = TileMapSKRenderer(tileMap: tileMap)
		do
		{
			try renderer.createTextureAtlas()
		}
		catch let e
		{
			XCTFail("renderer.createTextureAtlas threw \(e)")
		}
	}
}

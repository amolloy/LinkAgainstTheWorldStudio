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

    override func setUp() {
        super.setUp()
	}
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testLoadHeader() {
		let tileMapFile = TileMapFile(path: testMapPath)
		do
		{
			try tileMapFile.load()
		}
		catch let e
		{
			XCTFail("tileMapFile.load() threw \(e)")
		}

		XCTAssertTrue(tileMapFile.hasFORMTag, "TileMapFile has no FORM tag")
		XCTAssertTrue(tileMapFile.hasFMAPTag, "TileMapFile has no FMAP header")
		XCTAssertEqual(tileMapFile.dataLength, 45844)
	}


	
}

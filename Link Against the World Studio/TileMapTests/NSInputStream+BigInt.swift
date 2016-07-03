//
//  TileMapFileInt.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/31/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import XCTest
@testable import TileMap

class TileMapFileInt: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testTooShortBuffer() {
		var tooShort = [UInt8(0x20)];
		let short = Data(bytes: UnsafePointer<UInt8>(&tooShort), count: tooShort.count)
		let inputStream = InputStream(data: short)
		inputStream.open()
		let int = inputStream.readBigInt()
		XCTAssertTrue(int == nil)
	}

	func testReadBuffer() {
		var valid = [UInt8(0x00), UInt8(0x00), UInt8(0xB3), UInt8(0x14)]
		let validData = Data(bytes: UnsafePointer<UInt8>(&valid), count: valid.count)
		let inputStream = InputStream(data: validData)
		inputStream.open()
		guard let int = inputStream.readBigInt() else
		{
			XCTFail()
			return
		}
		XCTAssertEqual(int, 45844)
	}

}

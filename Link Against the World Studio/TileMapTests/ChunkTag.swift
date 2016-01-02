//
//  ChunkTag.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/31/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import XCTest
@testable import TileMap

class ChunkTagTests: XCTestCase {
	func testTooShortBuffer() {
		var tooShort = [UInt8(0x20)];
		let short = NSData(bytes: &tooShort, length: tooShort.count)
		let inputStream = NSInputStream(data: short)
		inputStream.open()

		let chunkTag = inputStream.readChunkTag()

		XCTAssert(chunkTag == nil)
	}

	func testStringInit() {
		let failedTag = ChunkTag(rawValue: "NO")
		XCTAssert(failedTag == nil)

		let workingTag = ChunkTag(rawValue: "FMAP")
		XCTAssert(workingTag != nil)
		XCTAssertEqual(workingTag!.tag[0], Char.F)
		XCTAssertEqual(workingTag!.tag[1], Char.M)
		XCTAssertEqual(workingTag!.tag[2], Char.A)
		XCTAssertEqual(workingTag!.tag[3], Char.P)
	}

	func testEquals() {
		guard let tag1 = ChunkTag(rawValue: "FMAP") else { XCTFail(); return }
		guard let tag2 = ChunkTag(rawValue: "FMAP") else { XCTFail(); return }

		XCTAssertEqual(tag1, tag2)

		guard let tag3 = ChunkTag(rawValue: "FMOD") else { XCTFail(); return }

		XCTAssertNotEqual(tag1, tag3)
	}

	func testNotEquals() {
		guard let tag1 = ChunkTag(rawValue: "FMAP") else { XCTFail(); return }
		guard let tag2 = ChunkTag(rawValue: "FMOD") else { XCTFail(); return }

		XCTAssertNotEqual(tag1, tag2)

		guard let tag3 = ChunkTag(rawValue: "FMAP") else { XCTFail(); return }

		XCTAssertEqual(tag1, tag3)
	}

	func testReadBuffer() {
		var valid = [Char.F.rawValue, Char.M.rawValue, Char.A.rawValue, Char.P.rawValue]
		let validData = NSData(bytes: &valid, length: valid.count)
		let inputStream = NSInputStream(data: validData)
		inputStream.open()

		guard let chunkTag = inputStream.readChunkTag() else { XCTFail(); return }
		guard let testTag = ChunkTag(rawValue: "FMAP") else { XCTFail(); return }
		XCTAssertEqual(chunkTag, testTag)
	}
}

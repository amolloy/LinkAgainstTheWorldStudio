//
//  TileMapFileInt.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/31/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

extension NSInputStream
{
	// Reads a big endian 4-byte signed integer from the stream and converts it to a native Int
	func readBigInt() -> Int?
	{
		var buf = [UInt8](count: 4, repeatedValue: 0)
		let readCount = read(&buf, maxLength: 4)
		var int : Int?
		if readCount == 4
		{
			int = Int(buf[3]) +
				(Int(buf[2]) << 8) +
				(Int(buf[1]) << 16) +
				(Int(buf[0]) << 24)
		}

		return int;
	}
}

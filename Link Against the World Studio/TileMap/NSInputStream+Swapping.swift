//
//  TileMapFileInt.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/31/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

extension InputStream
{
	// Reads a big endian 4-byte signed integer from the stream and converts it to a native Int
	func readBigInt() -> Int?
	{
		struct Static
		{
			static let hostByteOrder = __CFByteOrder(UInt32(CFByteOrderGetCurrent()))
		}
		return readInt32(Static.hostByteOrder == CFByteOrderLittleEndian)
	}

	func readInt32(_ swap: Bool) -> Int?
	{
		var buf = [UInt8](repeating: 0, count: 4)
		let readCount = read(&buf, maxLength: 4)
		var int : Int?
		if readCount == 4
		{
			if swap
			{
				int = Int(buf[3]) +
					(Int(buf[2]) << 8) +
					(Int(buf[1]) << 16) +
					(Int(buf[0]) << 24)
			}
			else
			{
				int = Int(buf[0]) +
					(Int(buf[1]) << 8) +
					(Int(buf[2]) << 16) +
					(Int(buf[3]) << 24)
			}
		}

		return int;
	}

	func readInt16(_ swap: Bool) -> Int16?
	{
		var buf = [UInt8](repeating: 0, count: 2)
		let readCount = read(&buf, maxLength: 2)
		var int : Int16?
		if readCount == 2
		{
			if swap
			{
				int = Int16(buf[1]) +
					(Int16(buf[0]) << 8)
			}
			else
			{
				int = Int16(buf[0]) +
					(Int16(buf[1]) << 8)
			}
		}

		return int;
	}

	func readUInt8() -> UInt8?
	{
		var buf = [UInt8](repeating: 0, count: 1)
		if read(&buf, maxLength: 1) == 1
		{
			return buf.first
		}
		else
		{
			return nil
		}
	}
}

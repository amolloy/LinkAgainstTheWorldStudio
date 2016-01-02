//
//  ArrayBuffer.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/8/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

protocol BufferContentsType: Comparable, IntegerLiteralConvertible, IntegerArithmeticType {
	init(_: Int8)
}

extension Int8: BufferContentsType {}

extension Array where Element : BufferContentsType
{
	func getIntAtIndex(index: Int, swapBytes: Bool) -> Int
	{
		let b1 = UInt32(unsafeBitCast(self[index + 0], UInt8.self))
		let b2 = UInt32(unsafeBitCast(self[index + 1], UInt8.self))
		let b3 = UInt32(unsafeBitCast(self[index + 2], UInt8.self))
		let b4 = UInt32(unsafeBitCast(self[index + 3], UInt8.self))

		let i : UInt32
		if swapBytes
		{
			i = b4 +
				(b3 << 8) +
				(b2 << 16) +
				(b1 << 24)
		}
		else
		{
			i = b1 +
				(b2 << 8) +
				(b3 << 16) +
				(b4 << 24)
		}
		return Int(unsafeBitCast(i, Int32.self))
	}
}
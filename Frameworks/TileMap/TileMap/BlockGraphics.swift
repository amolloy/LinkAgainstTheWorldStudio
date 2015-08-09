//
//  BlockGraphics.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/9/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

class BlockGraphics : Chunk
{
	let buffer : [UInt8]

	required init?(inputStream: NSInputStream, length: Int)
	{
		var bytes = [UInt8](count: length, repeatedValue: 0)
		guard inputStream.read(&bytes, maxLength: length) == length else
		{
			buffer = [UInt8]()
			return nil
		}
		buffer = bytes
	}

	func description() -> String {
		return "BGFX"
	}
}

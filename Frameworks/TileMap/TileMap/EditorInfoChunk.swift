//
//  EditorInfoChunk.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/3/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

// The EditorInfoChunk stores editor information such as the last offset
// into the map the user was editing, what size the editing screen was, 
// etc. We'll just ignore it since we won't be using it even in our editor.
class EditorInfoChunk : Chunk
{
	required init?(inputStream: NSInputStream, length: Int)
	{
		var bytes = [UInt8](count: length, repeatedValue: 0)
		guard inputStream.read(&bytes, maxLength: length) == length else
		{
			return nil
		}
	}

	func description() -> String {
		return "EditorInfoChunk (ignored)"
	}
}

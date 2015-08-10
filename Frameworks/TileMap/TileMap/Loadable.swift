//
//  Loadable.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/9/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

protocol Loadable
{
	static func registerWithTileMap(tileMap: TileMap)
	init?(inputStream: NSInputStream, dataLength: Int, tileMap: TileMap, chunkType: ChunkType)
}

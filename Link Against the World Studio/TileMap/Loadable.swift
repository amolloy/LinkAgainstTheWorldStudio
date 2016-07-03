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
	static func registerWithTileMap(_ tileMap: TileMap)
	init?(inputStream: InputStream, dataLength: Int, tileMap: TileMap, chunkType: ChunkType)
}

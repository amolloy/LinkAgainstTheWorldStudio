//
//  Map+TileMapImport.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/2/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation
import TileMap
import Map
import CrossPlatform
import ImageUtilities

func textureAtlasWithBlockSize(blockSize: TileMap.Size, textures: [Image]) -> Image?
{
	let textureCount = textures.count
	let texturesWide = Int(ceil(sqrt(CGFloat(textureCount))))
	let texturesHigh = (textureCount + texturesWide - 1) / texturesWide

	let atlasSize = TileMap.Size(texturesWide * blockSize.width, texturesHigh * blockSize.height)

	let cs = CGColorSpaceCreateDeviceRGB()

	let ctx = CGBitmapContextCreate(nil,
		atlasSize.width,
		atlasSize.height,
		8,
		atlasSize.width * 4,
		cs,
		CGImageAlphaInfo.PremultipliedLast.rawValue)

	CGContextClearRect(ctx, CGRect(x: 0, y: 0, width: CGFloat(atlasSize.width), height: CGFloat(atlasSize.height)))

	for i in 0..<textureCount
	{
		let texture = textures[i]
		let column = i % texturesWide
		let row = i / texturesWide
		let textureRect = CGRect(x: CGFloat(column * blockSize.width),
			y: CGFloat(row * blockSize.height),
			width: CGFloat(blockSize.width),
			height: CGFloat(blockSize.height))
		CGContextDrawImage(ctx, textureRect, texture.cgImage)
	}

	guard let cgImage = CGImageCreateWithCGContext(ctx) else { return nil }
	
	return Image(CGImage: cgImage, size: NSSize(atlasSize))
}

extension Map
{
	convenience init?(tileMap: TileMap) throws
	{
		self.init()

		guard let blockSize = tileMap.blockSize() else
		{
			return nil
		}
		let textures = try tileMap.textures()
		guard let atlasImage = textureAtlasWithBlockSize(blockSize, textures: textures) else
		{
			return nil
		}
		let tileSet = TileSet(image: atlasImage,
			imageName:  "tilemap.tiff",
			name: "Imported from TileMap",
			tileCount: textures.count,
			tileWidth: blockSize.width,
			tileHeight: blockSize.height)

		self.addTileSet(tileSet)
	}
}
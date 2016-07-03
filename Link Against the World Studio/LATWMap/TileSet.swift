//
//  TileSet.swift
//  LATWMap
//
//  Created by Andrew Molloy on 1/2/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation
import CrossPlatform

public final class TileSet
{
	public var image : Image?
	public let imageName : String
	public let name : String
	public let tileCount : Int
	public let tileWidth : Int
	public let tileHeight : Int

	public func coordinatesForTileAtIndex(_ index: Int) -> CGRect
	{
		guard let image = image else
		{
			return CGRect.zero
		}
		let tilesWide = Int(image.size.width) / tileWidth
		let row = index / tilesWide
		let col = index % tilesWide

		return CGRect(x: col * tileWidth, y: row * tileHeight, width: tileWidth, height: tileHeight)
	}

	public init(image: Image?, imageName: String, name: String, tileCount: Int, tileWidth: Int, tileHeight: Int)
	{
		self.image = image
		self.imageName = imageName
		self.name = name
		self.tileCount = tileCount
		self.tileWidth = tileWidth
		self.tileHeight = tileHeight
	}

	public func imageForTileAtIndex(_ index: Int) -> Image?
	{
		var coordinates = coordinatesForTileAtIndex(index)
		if coordinates == CGRect.zero
		{
			return nil
		}
		guard let image = image else { return nil }
		coordinates.origin.y = image.size.height - coordinates.origin.y
		coordinates.size.height = -coordinates.size.height
		guard let cgImage = image.cgImage,
			  let subImage = cgImage.cropping(to: coordinates) else
		{
			return nil
		}

		return Image(cgImage: subImage, size: coordinates.size)
	}
}

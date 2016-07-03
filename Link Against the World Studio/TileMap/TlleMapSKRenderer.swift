//
//  TlleMapSKRenderer.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/13/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation
import SpriteKit
import CrossPlatform

public class TileMapSKRenderer
{
	let tileMap : TileMap
	var textureAtlas : SKTextureAtlas?

	enum Error : ErrorProtocol
	{
		case missingTileMapHeader
		case missingBlockGraphics
		case missingBlockData
		case missingColorMap
		case invalidBlockImage
		case unsupportedColorDepth
		case cannotCreateDataProvider
		case cannotCreateImageFromData
		case missingTextureAtlas
	}

	public init(tileMap: TileMap)
	{
		self.tileMap = tileMap
		textureAtlas = nil
	}

	public func node() throws -> TileMapSKNode?
	{
		if self.textureAtlas == nil
		{
			do
			{
				try createTextureAtlas()
			}
			catch let e
			{
				assertionFailure("Couldn't create texture atlas: \(e)")
				return nil
			}
		}
		guard let textureAtlas = self.textureAtlas else
		{
			throw Error.missingTextureAtlas
		}
		let node = TileMapSKNode(tileMap: tileMap, textureAtlas: textureAtlas)

		// TODO this api is all wrong.
		var i = 0
		for layer in tileMap.layers
		{
			let sn = node.buildTilesForLayer(layer)
			if let sn = sn
			{
				sn.zPosition = CGFloat(i * 100)
				node.addChild(sn)
			}
			i += 1
		}

		return node
	}

	func createTextureAtlas() throws
	{
		let textures = try tileMap.textures()
		typealias Image = CrossPlatform.Image
		var textureAtlasInfo = [String: Image]()

		for i in 0..<textures.count
		{
			textureAtlasInfo[String(i)] = textures[i]
		}

		textureAtlas = SKTextureAtlas(dictionary: textureAtlasInfo)
	}
}

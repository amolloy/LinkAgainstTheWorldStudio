//
//  TileMapNode.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/10/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation
import SpriteKit
import LATWMap

public class TileMapNode : SKNode
{
	let map : Map
	let tileLayerNodes : [TileLayerNode]

	public init?(map: Map)
	{
		self.map = map

		var tileLayerNodes = [TileLayerNode]()
		for tileLayer in map.tileLayers
		{
			if let layerNode = TileLayerNode(tileLayer: tileLayer)
			{
				tileLayerNodes.append(layerNode)
			}
		}
		self.tileLayerNodes = tileLayerNodes

		super.init()

		tileLayerNodes.forEach()
		{
			self.addChild($0)
		}
	}

	required public init?(coder aDecoder: NSCoder)
	{
	    assertionFailure()
		map = Map()
		tileLayerNodes = [TileLayerNode]()
		super.init(coder: aDecoder)
	}
}

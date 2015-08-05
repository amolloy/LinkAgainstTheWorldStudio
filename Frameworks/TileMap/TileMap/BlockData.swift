//
//  BlockData.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/5/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

class BlockData : Chunk
{
	class BlockStructure
	{
		struct CollisionSet : OptionSetType
		{
			let rawValue : UInt8
			init(rawValue: UInt8)
			{
				self.rawValue = rawValue
			}

			static var None : CollisionSet { return CollisionSet(rawValue: 0) }
			static var tl : CollisionSet { return CollisionSet(rawValue: 1 << 0) }
			static var tr : CollisionSet { return CollisionSet(rawValue: 1 << 1) }
			static var bl : CollisionSet { return CollisionSet(rawValue: 1 << 2) }
			static var br : CollisionSet { return CollisionSet(rawValue: 1 << 3) }
		}

		let backgroundOffset : Int
		let foregroundOffsets : [Int]
		let user1 : Int
		let user2 : Int
		let user3 : Int16
		let user4 : Int16
		let user5 : UInt8
		let user6 : UInt8
		let user7 : UInt8
		let collision : CollisionSet
		let trigger : Bool
		let unused : [UInt8]

		init(backgroundOffset: Int,
			foregroundOffsets: [Int],
			user1: Int,
			user2: Int,
			user3: Int16,
			user4: Int16,
			user5: UInt8,
			user6: UInt8,
			user7: UInt8,
			collision : CollisionSet,
			trigger: Bool,
			unused: [UInt8])
		{
			self.backgroundOffset = backgroundOffset
			self.foregroundOffsets = foregroundOffsets
			self.user1 = user1
			self.user2 = user2
			self.user3 = user3
			self.user4 = user4
			self.user5 = user5
			self.user6 = user6
			self.user7 = user7
			self.collision = collision
			self.trigger = trigger
			self.unused = unused
		}
	}

	let blockStructures : [BlockStructure]

	required init?(inputStream: NSInputStream, length: Int, mapHeader: MapHeader) {
		var blockStructures = [BlockStructure]()
		let blockSize = mapHeader.blockStructureSize

		if length % blockSize != 0
		{
			self.blockStructures = blockStructures
			return nil
		}

		let blockCount = length / blockSize

		for i in 0..<blockCount
		{
			print("\(i)")
		}

		self.blockStructures = blockStructures
	}

	func description() -> String {
		return "BlockData"
	}
}

//
//  BlockData.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/5/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

public class BlockData : Loadable
{
	public class BlockStructure : Tileable
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

		public let backgroundIndex : Int
		public let foregroundIndices : [Int]
		let user1 : Int
		let user2 : Int
		let user3 : Int16
		let user4 : Int16
		let user5 : UInt8
		let user6 : UInt8
		let user7 : UInt8
		let collision : CollisionSet
		let trigger : Bool
		let unused : [Bool]

		init(backgroundIndex: Int,
			foregroundIndices: [Int],
			user1: Int,
			user2: Int,
			user3: Int16,
			user4: Int16,
			user5: UInt8,
			user6: UInt8,
			user7: UInt8,
			collision : CollisionSet,
			trigger: Bool,
			unused: [Bool])
		{
			self.backgroundIndex = backgroundIndex
			self.foregroundIndices = foregroundIndices
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

	public let blockStructures : [BlockStructure]

	required public init?(inputStream: NSInputStream, dataLength: Int, tileMap: TileMap, chunkType: ChunkType)
	{
		var blockStructures = [BlockStructure]()

		guard let mapHeader = tileMap.mapHeader else
		{
			self.blockStructures = blockStructures
			return nil
		}
		let swapBytes = mapHeader.swapBytes
		let blockSize = mapHeader.blockStructureSize

		if dataLength % blockSize != 0
		{
			self.blockStructures = blockStructures
			return nil
		}

		let blockCount = dataLength / blockSize

		for _ in 0..<blockCount
		{
			guard let bgoff = inputStream.readInt32(swapBytes) else
			{
				self.blockStructures = blockStructures
				return nil
			}
			guard let fgoff1 = inputStream.readInt32(swapBytes) else
			{
				self.blockStructures = blockStructures
				return nil
			}
			guard let fgoff2 = inputStream.readInt32(swapBytes) else
			{
				self.blockStructures = blockStructures
				return nil
			}
			guard let fgoff3 = inputStream.readInt32(swapBytes) else
			{
				self.blockStructures = blockStructures
				return nil
			}
			let bgIndex : Int
			let fgIndices : [Int]
			if (mapHeader.mapType > .FMP05)
			{
				bgIndex = bgoff
				fgIndices = [fgoff1, fgoff2, fgoff3]
			}
			else
			{
				let blockWidth = Int(mapHeader.blockSize.width)
				let blockHeight = Int(mapHeader.blockSize.height)
				let blockDepth = mapHeader.blockColorDepth
				bgIndex = bgoff / (blockWidth * blockHeight * ((blockDepth + 1) / 8))
				let fgIndex1 = fgoff1 / (blockWidth * blockHeight * ((blockDepth + 1) / 8))
				let fgIndex2 = fgoff2 / (blockWidth * blockHeight * ((blockDepth + 1) / 8))
				let fgIndex3 = fgoff3 / (blockWidth * blockHeight * ((blockDepth + 1) / 8))
				fgIndices = [fgIndex1, fgIndex2, fgIndex3]
			}
			guard let user1 = inputStream.readInt32(swapBytes) else
			{
				self.blockStructures = blockStructures
				return nil
			}
			guard let user2 = inputStream.readInt32(swapBytes) else
			{
				self.blockStructures = blockStructures
				return nil
			}
			guard let user3 = inputStream.readInt16(swapBytes) else
			{
				self.blockStructures = blockStructures
				return nil
			}
			guard let user4 = inputStream.readInt16(swapBytes) else
			{
				self.blockStructures = blockStructures
				return nil
			}
			guard let user5 = inputStream.readUInt8() else
			{
				self.blockStructures = blockStructures
				return nil
			}
			guard let user6 = inputStream.readUInt8() else
			{
				self.blockStructures = blockStructures
				return nil
			}
			guard let user7 = inputStream.readUInt8() else
			{
				self.blockStructures = blockStructures
				return nil
			}
			guard let bitfield = inputStream.readUInt8() else
			{
				self.blockStructures = blockStructures
				return nil
			}

			let unused = [(bitfield & 0x20) == 0x20,
				(bitfield & 0x40) == 0x40,
				(bitfield & 0x80) == 0x80]

			let trigger = (bitfield & 0x10) == 0x10

			let collision = BlockStructure.CollisionSet(rawValue: bitfield & 0x0F)

			let block = BlockStructure(backgroundIndex: bgIndex,
				foregroundIndices: fgIndices,
				user1: user1,
				user2: user2,
				user3: user3,
				user4: user4,
				user5: user5,
				user6: user6,
				user7: user7,
				collision: collision,
				trigger: trigger,
				unused: unused)

			blockStructures.append(block)
		}

		self.blockStructures = blockStructures

		tileMap.blockData = self
	}

	static func registerWithTileMap(tileMap: TileMap)
	{
		tileMap.registerLoadable(self, chunkType: ChunkType.BKDT)
	}
}

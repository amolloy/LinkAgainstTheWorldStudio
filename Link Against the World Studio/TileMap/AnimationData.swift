//
//  AnimationData.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/6/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

public class AnimationData : Loadable
{
	public class AnimationStructure : Tileable
	{
		enum AnimType : Int8
		{
			case end = -1
			case none
			case loopForward
			case loopReverse
			case once
			case onceAndHalt
			case pongForwardOutwardLeg
			case pongForwardReturnLeg
			case pongReverseOutwardLeg
			case pongReverseReturnLeg
			case onceFinished
		}

		let animType : AnimType
		let animDelay : Int8
		let animCounter : Int8
		let animUser : Int8
		let frameIndex : Int
		let frames : [Int]

		init(animType: AnimType,
			animDelay: Int8,
			animCounter: Int8,
			animUser: Int8,
			frameIndex: Int,
			frames: [Int])
		{
			self.animType = animType
			self.animDelay = animDelay
			self.animCounter = animCounter
			self.animUser = animUser
			self.frameIndex = frameIndex
			self.frames = frames
		}
	}

	let animationStructures : [AnimationStructure]

	required public init?(inputStream: NSInputStream, dataLength: Int, tileMap: TileMap, chunkType: ChunkType)
	{
		guard let mapHeader = tileMap.mapHeader else
		{
			animationStructures = [AnimationStructure]()
			return nil
		}
		let swapBytes = mapHeader.swapBytes

		var uChunkData = [UInt8](count: dataLength, repeatedValue: 0)
		if inputStream.read(&uChunkData, maxLength: dataLength) != dataLength
		{
			animationStructures = [AnimationStructure]()
			return nil
		}
		let chunkData = unsafeBitCast(uChunkData, [Int8].self)

		let intSize : Int
		let imageSize : Int

		if mapHeader.mapType == .FMP05
		{
			intSize = 4
			imageSize = mapHeader.blockStructureSize
		}
		else
		{
			intSize = 1
			imageSize = 1
		}

		var animStructures = [AnimationStructure]()
		var readPtr = chunkData.count - 16

		while ((AnimationStructure.AnimType(rawValue: chunkData[readPtr]) ?? .end) != .end)
		{
			let animType = AnimationStructure.AnimType(rawValue: chunkData[readPtr]) ?? .end

			let delay = chunkData[readPtr + 1]
			let delayCountdown = chunkData[readPtr + 2]
			let userData = chunkData[readPtr + 3]

			var offset1 = chunkData.getIntAtIndex(readPtr + 8, swapBytes: swapBytes)
			let offset2 = chunkData.getIntAtIndex(readPtr + 12, swapBytes: swapBytes)
			let frameCount = (offset2 - offset1) / intSize
			let startFrame = (chunkData.getIntAtIndex(readPtr + 4, swapBytes: swapBytes) - offset1) / intSize

			var frameIndex = 0
			if frameCount > 0
			{
				frameIndex = startFrame
			}

			if mapHeader.mapType != .FMP05
			{
				offset1 = (offset1 * 4) - dataLength
			}

			var frames = [Int]()
			for _ in 0..<frameCount
			{
				let frameNo = chunkData.getIntAtIndex(dataLength + offset1 - 4, swapBytes: swapBytes)
				frames.append(frameNo / imageSize)
				offset1 += 4
			}

			readPtr -= 16

			let s = AnimationStructure(animType: animType,
				animDelay: delay,
				animCounter: delayCountdown,
				animUser: userData,
				frameIndex: frameIndex,
				frames: frames)

			animStructures.append(s)
		}
		self.animationStructures = animStructures

		tileMap.animationData = self
	}

	static func registerWithTileMap(tileMap: TileMap)
	{
		tileMap.registerLoadable(self, chunkType: ChunkType.ANDT)
	}
}

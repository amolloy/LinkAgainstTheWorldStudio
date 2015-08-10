//
//  MapHeader.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/3/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

class MapHeader : Loadable
{
	enum MapType : UInt8, Comparable
	{
		case FMP05
		case FMP10
		case FMP10RLE
	}

	struct Size
	{
		let width : Int
		let height : Int
		init(_ width: Int, _ height: Int)
		{
			self.width = width
			self.height = height
		}
		init(_ width: Int16, _ height: Int16)
		{
			self.init(Int(width), Int(height))
		}
		init()
		{
			self.init(0, 0)
		}
	}

	let mapVersion : NSDecimalNumber
	let swapBytes : Bool
	let mapType : MapType
	let mapSize : Size
	let reserved1 : Int
	let reserved2 : Int
	let blockSize : Size
	let blockColorDepth : Int
	let blockStructureSize : Int
	let blockStructureCount : Int
	let blockGFXCount : Int
	let keyColor : NSColor?
	let keyColor8Bit : UInt8
	let blockGap : Size
	let blockStagger : Size
	let clickMask : Int
	let pillars : Int

	required init?(inputStream: NSInputStream, dataLength: Int, tileMap: TileMap, chunkType: ChunkType)
	{
		guard let versionHigh = inputStream.readUInt8(),
			let versionLow = inputStream.readUInt8() else
		{
			// Ugh, this all appears to be required due to an as-of-yet
			// addressed compiler bug:
			// https://devforums.apple.com/thread/251388?start=0&tstart=0#1062922
			mapVersion = NSDecimalNumber()
			swapBytes = true
			mapType = .FMP05
			mapSize = Size()
			self.reserved1 = 0
			self.reserved2 = 0
			blockSize = Size()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = Size()
			blockStagger = Size()
			clickMask = 0
			pillars = 0
			return nil
		}
		mapVersion = NSDecimalNumber(string: "\(versionHigh).\(versionLow)")

		guard let lsb = inputStream.readUInt8() else
		{
			swapBytes = true
			mapType = .FMP05
			mapSize = Size()
			self.reserved1 = 0
			self.reserved2 = 0
			blockSize = Size()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = Size()
			blockStagger = Size()
			clickMask = 0
			pillars = 0
			return nil
		}
		let hostByteOrder = __CFByteOrder(UInt32(CFByteOrderGetCurrent()))
		let hostLsb = hostByteOrder == CFByteOrderLittleEndian
		// if 1, data stored LSB first, otherwise MSB first.
		swapBytes = hostLsb != (lsb == 1)

		/* 0 for 32 offset still, -16 offset anim shorts in BODY added FMP0.5*/
		guard let mapTypeChar = inputStream.readUInt8() else
		{
			mapType = .FMP05
			mapSize = Size()
			self.reserved1 = 0
			self.reserved2 = 0
			blockSize = Size()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = Size()
			blockStagger = Size()
			clickMask = 0
			pillars = 0
			return nil
		}

		guard let theMapType = MapType(rawValue: mapTypeChar) else
		{
			// TODO throw too new
			mapType = .FMP05
			mapSize = Size()
			self.reserved1 = 0
			self.reserved2 = 0
			blockSize = Size()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = Size()
			blockStagger = Size()
			clickMask = 0
			pillars = 0
			return nil
		}
		mapType = theMapType

		guard let mapWidth = inputStream.readInt16(swapBytes),
			let mapHeight = inputStream.readInt16(swapBytes) else
		{
			mapSize = Size()
			self.reserved1 = 0
			self.reserved2 = 0
			blockSize = Size()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = Size()
			blockStagger = Size()
			clickMask = 0
			pillars = 0
			return nil
		}
		mapSize = Size(mapWidth, mapHeight)

		guard let reserved1 = inputStream.readInt16(swapBytes),
			let reserved2 = inputStream.readInt16(swapBytes) else
		{
			self.reserved1 = 0
			self.reserved2 = 0
			blockSize = Size()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = Size()
			blockStagger = Size()
			clickMask = 0
			pillars = 0
			return nil
		}
		self.reserved1 = Int(reserved1)
		self.reserved2 = Int(reserved2)

		guard let blockWidth = inputStream.readInt16(swapBytes),
			let blockHeight = inputStream.readInt16(swapBytes) else
		{
			blockSize = Size()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = Size()
			blockStagger = Size()
			clickMask = 0
			pillars = 0
			return nil
		}
		blockSize = Size(blockWidth, blockHeight)

		guard let blockDepth = inputStream.readInt16(swapBytes) else
		{
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = Size()
			blockStagger = Size()
			clickMask = 0
			pillars = 0
			return nil
		}
		blockColorDepth = Int(blockDepth)

		guard let blockStrSize = inputStream.readInt16(swapBytes) else
		{
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = Size()
			blockStagger = Size()
			clickMask = 0
			pillars = 0
			return nil
		}
		blockStructureSize = Int(blockStrSize)

		guard let numBlockStr = inputStream.readInt16(swapBytes) else
		{
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = Size()
			blockStagger = Size()
			clickMask = 0
			pillars = 0
			return nil
		}
		blockStructureCount = Int(numBlockStr)

		guard let numBlockGfx = inputStream.readInt16(swapBytes) else
		{
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = Size()
			blockStagger = Size()
			clickMask = 0
			pillars = 0
			return nil
		}
		blockGFXCount = Int(numBlockGfx)

		if dataLength > 24
		{
			guard let ckey8bit = inputStream.readUInt8(),
				let ckeyred = inputStream.readUInt8(),
				let ckeygreen = inputStream.readUInt8(),
				let ckeyblue = inputStream.readUInt8() else
			{
				keyColor8Bit = 0
				keyColor = NSColor()
				blockGap = Size()
				blockStagger = Size()
				clickMask = 0
				pillars = 0
				return nil
			}
			keyColor8Bit = ckey8bit
			keyColor = NSColor(red: CGFloat(ckeyred) / CGFloat(0xFF),
				green: CGFloat(ckeygreen) / CGFloat(0xFF),
				blue: CGFloat(ckeyblue) / CGFloat(0xFF),
				alpha: 1)
		}
		else
		{
			keyColor8Bit = 0
			keyColor = nil
		}

		if dataLength > 28
		{
			guard let blockGapX = inputStream.readInt16(swapBytes),
				let blockGapY = inputStream.readInt16(swapBytes),
				let blockStaggerX = inputStream.readInt16(swapBytes),
				let blockStaggerY = inputStream.readInt16(swapBytes) else
			{
				blockGap = Size()
				blockStagger = Size()
				clickMask = 0
				pillars = 0
				return nil
			}
			blockGap = Size(blockGapX, blockGapY)
			blockStagger = Size(blockStaggerX, blockStaggerY)
		}
		else
		{
			blockGap = blockSize;
			blockStagger = Size()
		}

		if dataLength > 36
		{
			guard let cm = inputStream.readInt16(swapBytes) 			else
			{
				clickMask = 0
				pillars = 0
				return nil
			}
			clickMask = Int(cm)
		}
		else
		{
			clickMask = 0
		}

		if dataLength > 38
		{
			guard let pil = inputStream.readInt16(swapBytes) else
			{
				pillars = 0
				return nil
			}
			pillars = Int(pil)
		}
		else
		{
			pillars = 0
		}

		tileMap.mapHeader = self
	}

	static func registerWithTileMap(tileMap: TileMap)
	{
		tileMap.registerLoadable(self, chunkType: ChunkType.MPHD)
	}
}

func <(lhs: MapHeader.MapType, rhs: MapHeader.MapType) -> Bool
{
	return lhs.rawValue < rhs.rawValue
}

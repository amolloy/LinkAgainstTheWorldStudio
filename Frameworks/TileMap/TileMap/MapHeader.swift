//
//  MapHeader.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/3/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

class MapHeader : Chunk
{
	let mapVersion : NSDecimalNumber
	let needsBytesFlipped : Bool
	let mapType : Int // TODO Probably make an enum once I know what this is
	let mapSize : CGSize
	let reserved1 : Int
	let reserved2 : Int
	let blockSize : CGSize
	let blockColorDepth : Int
	let blockStructureSize : Int
	let blockStructureCount : Int
	let blockGFXCount : Int
	let keyColor : NSColor?
	let keyColor8Bit : UInt8
	let blockGap : CGSize
	let blockStagger : CGSize
	let clickMask : Int
	let pillars : Int

	required init?(inputStream: NSInputStream, length: Int) {
		guard let versionHigh = inputStream.readUInt8(),
			let versionLow = inputStream.readUInt8() else
		{
			// Ugh, this all appears to be required due to an as-of-yet
			// addressed compiler bug:
			// https://devforums.apple.com/thread/251388?start=0&tstart=0#1062922
			mapVersion = NSDecimalNumber()
			needsBytesFlipped = true
			mapType = 0
			mapSize = CGSize()
			self.reserved1 = 0
			self.reserved2 = 0
			blockSize = CGSize()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = CGSize()
			blockStagger = CGSize()
			clickMask = 0
			pillars = 0
			return nil
		}
		mapVersion = NSDecimalNumber(string: "\(versionHigh).\(versionLow)")

		guard let lsb = inputStream.readUInt8() else
		{
			needsBytesFlipped = true
			mapType = 0
			mapSize = CGSize()
			self.reserved1 = 0
			self.reserved2 = 0
			blockSize = CGSize()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = CGSize()
			blockStagger = CGSize()
			clickMask = 0
			pillars = 0
			return nil
		}
		let hostByteOrder = __CFByteOrder(UInt32(CFByteOrderGetCurrent()))
		let hostLsb = hostByteOrder == CFByteOrderLittleEndian
		// if 1, data stored LSB first, otherwise MSB first.
		needsBytesFlipped = hostLsb != (lsb == 1)

		/* 0 for 32 offset still, -16 offset anim shorts in BODY added FMP0.5*/
		guard let mapTypeChar = inputStream.readUInt8() else
		{
			mapType = 0
			mapSize = CGSize()
			self.reserved1 = 0
			self.reserved2 = 0
			blockSize = CGSize()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = CGSize()
			blockStagger = CGSize()
			clickMask = 0
			pillars = 0
			return nil
		}
		mapType = Int(mapTypeChar)

		if mapType > 3
		{
			// TODO throw too new
			mapSize = CGSize()
			self.reserved1 = 0
			self.reserved2 = 0
			blockSize = CGSize()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = CGSize()
			blockStagger = CGSize()
			clickMask = 0
			pillars = 0
			return nil
		}

		guard let mapWidth = inputStream.readInt16(needsBytesFlipped),
			let mapHeight = inputStream.readInt16(needsBytesFlipped) else
		{
			mapSize = CGSize()
			self.reserved1 = 0
			self.reserved2 = 0
			blockSize = CGSize()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = CGSize()
			blockStagger = CGSize()
			clickMask = 0
			pillars = 0
			return nil
		}
		mapSize = CGSizeMake(CGFloat(mapWidth), CGFloat(mapHeight))

		guard let reserved1 = inputStream.readInt16(needsBytesFlipped),
			let reserved2 = inputStream.readInt16(needsBytesFlipped) else
		{
			self.reserved1 = 0
			self.reserved2 = 0
			blockSize = CGSize()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = CGSize()
			blockStagger = CGSize()
			clickMask = 0
			pillars = 0
			return nil
		}
		self.reserved1 = reserved1
		self.reserved2 = reserved2

		guard let blockWidth = inputStream.readInt16(needsBytesFlipped),
			let blockHeight = inputStream.readInt16(needsBytesFlipped) else
		{
			blockSize = CGSize()
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = CGSize()
			blockStagger = CGSize()
			clickMask = 0
			pillars = 0
			return nil
		}
		blockSize = CGSizeMake(CGFloat(blockWidth), CGFloat(blockHeight))

		guard let blockDepth = inputStream.readInt16(needsBytesFlipped) else
		{
			blockColorDepth = 0
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = CGSize()
			blockStagger = CGSize()
			clickMask = 0
			pillars = 0
			return nil
		}
		blockColorDepth = blockDepth

		guard let blockStrSize = inputStream.readInt16(needsBytesFlipped) else
		{
			blockStructureSize = 0
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = CGSize()
			blockStagger = CGSize()
			clickMask = 0
			pillars = 0
			return nil
		}
		blockStructureSize = blockStrSize

		guard let numBlockStr = inputStream.readInt16(needsBytesFlipped) else
		{
			blockStructureCount = 0
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = CGSize()
			blockStagger = CGSize()
			clickMask = 0
			pillars = 0
			return nil
		}
		blockStructureCount = numBlockStr

		guard let numBlockGfx = inputStream.readInt16(needsBytesFlipped) else
		{
			blockGFXCount = 0
			keyColor = NSColor()
			keyColor8Bit = 0
			blockGap = CGSize()
			blockStagger = CGSize()
			clickMask = 0
			pillars = 0
			return nil
		}
		blockGFXCount = numBlockGfx

		if length > 24
		{
			guard let ckey8bit = inputStream.readUInt8(),
				let ckeyred = inputStream.readUInt8(),
				let ckeygreen = inputStream.readUInt8(),
				let ckeyblue = inputStream.readUInt8() else
			{
				keyColor8Bit = 0
				keyColor = NSColor()
				blockGap = CGSize()
				blockStagger = CGSize()
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

		if length > 28
		{
			guard let blockGapX = inputStream.readInt16(needsBytesFlipped),
				let blockGapY = inputStream.readInt16(needsBytesFlipped),
				let blockStaggerX = inputStream.readInt16(needsBytesFlipped),
				let blockStaggerY = inputStream.readInt16(needsBytesFlipped) else
			{
				blockGap = CGSize()
				blockStagger = CGSize()
				clickMask = 0
				pillars = 0
				return nil
			}
			blockGap = CGSizeMake(CGFloat(blockGapX), CGFloat(blockGapY))
			blockStagger = CGSizeMake(CGFloat(blockStaggerX), CGFloat(blockStaggerY))
		}
		else
		{
			blockGap = blockSize;
			blockStagger = CGSizeZero
		}

		if length > 36
		{
			guard let cm = inputStream.readInt16(needsBytesFlipped) 			else
			{
				clickMask = 0
				pillars = 0
				return nil
			}
			clickMask = cm
		}
		else
		{
			clickMask = 0
		}

		if length > 38
		{
			guard let pil = inputStream.readInt16(needsBytesFlipped) else
			{
				pillars = 0
				return nil
			}
			pillars = pil
		}
		else
		{
			pillars = 0
		}
	}

	func description() -> String {
		return "MapHeader"
	}
}
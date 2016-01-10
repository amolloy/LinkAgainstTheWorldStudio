//
//  TileMap+Textures.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/2/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation
import CrossPlatform

extension TileMap
{
	enum TileMapTexturesError : ErrorType
	{
		case MissingTileMapHeader
		case MissingBlockGraphics
		case MissingBlockData
		case MissingColorMap
		case InvalidBlockImage
		case UnsupportedColorDepth
		case CannotCreateDataProvider
		case CannotCreateImageFromData
		case MissingTextureAtlas
	}

	public func textures() throws -> [Image]
	{
		guard let mapHeader = mapHeader else
		{
			throw TileMapTexturesError.MissingTileMapHeader
		}
		guard let buffer = blockGraphics?.buffer else
		{
			throw TileMapTexturesError.MissingBlockGraphics
		}

		let blockWidth = Int(mapHeader.blockSize.width)
		let blockHeight = Int(mapHeader.blockSize.height)
		let blockDepth = mapHeader.blockColorDepth
		let bytesPerPixel = (blockDepth + 1) / 8
		let blockDataSize = blockWidth * blockHeight * bytesPerPixel
		let blockCount = buffer.count / blockDataSize

		let cs = CGColorSpaceCreateDeviceRGB()!

		var textures = [Image]()
		for i in 0..<blockCount
		{
			let offset = i * blockDataSize
			let subBuffer = buffer[offset..<(offset + blockDataSize)]

			let cgImage : CGImageRef
			if mapHeader.blockColorDepth == 8
			{
				guard let colorMap = colorMap else
				{
					throw TileMapTexturesError.MissingColorMap
				}

				cgImage = try create8BitTexture(mapHeader.blockSize,
					colorSpace: cs,
					buffer: subBuffer,
					colorMap: colorMap,
					keyColor: mapHeader.keyColor8Bit)
			}
			else if mapHeader.blockColorDepth == 15 || mapHeader.blockColorDepth == 16
			{
				// TODO
				throw TileMapTexturesError.UnsupportedColorDepth
			}
			else if mapHeader.blockColorDepth == 24
			{
				cgImage = try create24BitTexture(mapHeader.blockSize,
					colorSpace:cs,
					buffer: subBuffer,
					keyColor: mapHeader.keyColor)
			}
			else if mapHeader.blockColorDepth == 32
			{
				// TODO
				throw TileMapTexturesError.UnsupportedColorDepth
			}
			else
			{
				throw TileMapTexturesError.UnsupportedColorDepth
			}

			textures.append(Image(CGImage: cgImage, size: NSSize(mapHeader.blockSize)))
		}

		return textures
	}

	func create8BitTexture(blockSize: MapHeader.Size,
		colorSpace: CGColorSpaceRef,
		buffer: ArraySlice<UInt8>,
		colorMap: ColorMap,
		keyColor: UInt8) throws -> CGImageRef
	{
		var rgbBuffer = [UInt8]()
		rgbBuffer.reserveCapacity(buffer.count * 4)

		for key in buffer
		{
			if keyColor == key
			{
				rgbBuffer.append(0);
				rgbBuffer.append(0);
				rgbBuffer.append(0);
				rgbBuffer.append(0);
			}
			else
			{
				let (r, g, b) = colorMap.palette[Int(key)]
				rgbBuffer.append(r);
				rgbBuffer.append(g);
				rgbBuffer.append(b);
				rgbBuffer.append(0xFF);
			}
		}

		let rgbData = NSData(bytes: &rgbBuffer, length: rgbBuffer.count)
		guard let provider = CGDataProviderCreateWithCFData(rgbData) else
		{
			throw TileMapTexturesError.CannotCreateDataProvider
		}

		guard let cgImage = CGImageCreate(blockSize.width,
			blockSize.height,
			8,
			32,
			blockSize.width * 4,
			colorSpace,
			CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue),
			provider,
			nil,
			true,
			CGColorRenderingIntent.RenderingIntentDefault) else
		{
			throw TileMapTexturesError.InvalidBlockImage
		}
		return cgImage
	}

	func create24BitTexture(blockSize: MapHeader.Size,
		colorSpace: CGColorSpaceRef,
		buffer: ArraySlice<UInt8>,
		keyColor: TileMap.Color) throws -> CGImageRef
	{
		assert(buffer.count % 3 == 0)

		var rgbBuffer = [UInt8]()
		rgbBuffer.reserveCapacity((buffer.count / 3) * 4)

		for i in 0..<(buffer.count / 3)
		{
			let r = buffer[i * 3 + 0]
			let g = buffer[i * 3 + 1]
			let b = buffer[i * 3 + 2]

			let color : TileMap.Color = TileMap.Color(r: r, g: g, b: b)

			rgbBuffer.append(r)
			rgbBuffer.append(g)
			rgbBuffer.append(b)

			if keyColor == color
			{
				rgbBuffer.append(0);
			}
			else
			{
				rgbBuffer.append(0xFF);
			}
		}

		let rgbData = NSData(bytes: &rgbBuffer, length: rgbBuffer.count)
		guard let provider = CGDataProviderCreateWithCFData(rgbData) else
		{
			throw TileMapTexturesError.CannotCreateDataProvider
		}

		guard let cgImage = CGImageCreate(blockSize.width,
			blockSize.height,
			8,
			32,
			blockSize.width * 4,
			colorSpace,
			CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue),
			provider,
			nil,
			true,
			CGColorRenderingIntent.RenderingIntentDefault) else
		{
			throw TileMapTexturesError.InvalidBlockImage
		}
		return cgImage
	}
}

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
	enum TileMapTexturesError : ErrorProtocol
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

	public func textures() throws -> [Image]
	{
		guard let mapHeader = mapHeader else
		{
			throw TileMapTexturesError.missingTileMapHeader
		}
		guard let buffer = blockGraphics?.buffer else
		{
			throw TileMapTexturesError.missingBlockGraphics
		}

		let blockWidth = Int(mapHeader.blockSize.width)
		let blockHeight = Int(mapHeader.blockSize.height)
		let blockDepth = mapHeader.blockColorDepth
		let bytesPerPixel = (blockDepth + 1) / 8
		let blockDataSize = blockWidth * blockHeight * bytesPerPixel
		let blockCount = buffer.count / blockDataSize

		let cs = CGColorSpaceCreateDeviceRGB()

		var textures = [Image]()
		for i in 0..<blockCount
		{
			let offset = i * blockDataSize
			let subBuffer = buffer[offset..<(offset + blockDataSize)]

			let cgImage : CGImage
			if mapHeader.blockColorDepth == 8
			{
				guard let colorMap = colorMap else
				{
					throw TileMapTexturesError.missingColorMap
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
				throw TileMapTexturesError.unsupportedColorDepth
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
				throw TileMapTexturesError.unsupportedColorDepth
			}
			else
			{
				throw TileMapTexturesError.unsupportedColorDepth
			}

			textures.append(Image(cgImage: cgImage, size: NSSize(mapHeader.blockSize)))
		}

		return textures
	}

	func create8BitTexture(_ blockSize: MapHeader.Size,
		colorSpace: CGColorSpace,
		buffer: ArraySlice<UInt8>,
		colorMap: ColorMap,
		keyColor: UInt8) throws -> CGImage
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

		let rgbData = Data(bytes: UnsafePointer<UInt8>(&rgbBuffer), count: rgbBuffer.count)
		guard let provider = CGDataProvider(data: rgbData) else
		{
			throw TileMapTexturesError.cannotCreateDataProvider
		}

		guard let cgImage = CGImage(width: blockSize.width,
			height: blockSize.height,
			bitsPerComponent: 8,
			bitsPerPixel: 32,
			bytesPerRow: blockSize.width * 4,
			space: colorSpace,
			bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
			provider: provider,
			decode: nil,
			shouldInterpolate: true,
			intent: CGColorRenderingIntent.defaultIntent) else
		{
			throw TileMapTexturesError.invalidBlockImage
		}
		return cgImage
	}

	func create24BitTexture(_ blockSize: MapHeader.Size,
		colorSpace: CGColorSpace,
		buffer: ArraySlice<UInt8>,
		keyColor: TileMap.Color) throws -> CGImage
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

		let rgbData = Data(bytes: UnsafePointer<UInt8>(&rgbBuffer), count: rgbBuffer.count)
		guard let provider = CGDataProvider(data: rgbData) else
		{
			throw TileMapTexturesError.cannotCreateDataProvider
		}

		guard let cgImage = CGImage(width: blockSize.width,
			height: blockSize.height,
			bitsPerComponent: 8,
			bitsPerPixel: 32,
			bytesPerRow: blockSize.width * 4,
			space: colorSpace,
			bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
			provider: provider,
			decode: nil,
			shouldInterpolate: true,
			intent: CGColorRenderingIntent.defaultIntent) else
		{
			throw TileMapTexturesError.invalidBlockImage
		}
		return cgImage
	}
}

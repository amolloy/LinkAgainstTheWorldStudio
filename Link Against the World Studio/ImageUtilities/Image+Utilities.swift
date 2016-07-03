//
//  Image+Utilities.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/3/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation

public func CGImageCreateWithCGContext(_ ctx: CGContext?) -> CGImage?
{
	guard let ctx = ctx else { return nil }

	let ctxBytes = ctx.data
	if ctxBytes == nil
	{
		// Not a bitmap context
		return nil;
	}
	
	let width = ctx.width
	let stride = ctx.bytesPerRow
	let height = ctx.height

	let ctxData = Data(bytes: UnsafePointer<UInt8>(ctxBytes!), count:stride *  height)
	let provider = CGDataProvider(data: ctxData)

	let image = CGImage(width: width, height: height,
		bitsPerComponent: ctx.bitsPerComponent,
		bitsPerPixel: ctx.bitsPerPixel,
		bytesPerRow: stride,
		space: ctx.colorSpace!,
		bitmapInfo: ctx.bitmapInfo,
		provider: provider!,
		decode: nil,
		shouldInterpolate: false,
		intent: .defaultIntent)

	return image
}

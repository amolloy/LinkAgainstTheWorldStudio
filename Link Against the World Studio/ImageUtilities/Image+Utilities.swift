//
//  Image+Utilities.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/3/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation

public func CGImageCreateWithCGContext(ctx: CGContext?) -> CGImage?
{
	guard let ctx = ctx else { return nil }

	let ctxBytes = CGBitmapContextGetData(ctx)
	if ctxBytes == nil
	{
		// Not a bitmap context
		return nil;
	}
	
	let width = CGBitmapContextGetWidth(ctx)
	let stride = CGBitmapContextGetBytesPerRow(ctx)
	let height = CGBitmapContextGetHeight(ctx)

	let ctxData = NSData(bytes: ctxBytes, length:stride *  height)
	let provider = CGDataProviderCreateWithCFData(ctxData)

	let image = CGImageCreate(width, height,
		CGBitmapContextGetBitsPerComponent(ctx),
		CGBitmapContextGetBitsPerPixel(ctx),
		stride,
		CGBitmapContextGetColorSpace(ctx),
		CGBitmapContextGetBitmapInfo(ctx),
		provider,
		nil,
		false,
		.RenderingIntentDefault)

	return image
}

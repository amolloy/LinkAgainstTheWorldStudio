//
//  ColorMapChunk.swift
//  TileMap
//
//  Created by Andrew Molloy on 8/5/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

class ColorMap : Chunk
{
	let palette : [NSColor]

	required init?(inputStream: NSInputStream, length: Int) {
		if length % 3 != 0
		{
			palette = [NSColor]()
			return nil
		}

		var p = [NSColor]()
		let numColors = length / 3

		for _ in 0..<numColors
		{
			guard let red = inputStream.readUInt8(),
			let green = inputStream.readUInt8(),
			let blue = inputStream.readUInt8() else
			{
				palette = [NSColor]()
				return nil
			}

			let color = NSColor(red: CGFloat(red) / CGFloat(0xFF),
				green: CGFloat(green) / CGFloat(0xFF),
				blue: CGFloat(blue) / CGFloat(0xFF),
				alpha: 1)

			p.append(color)
		}

		palette = p
	}

	func description() -> String {
		return "ColorMap"
	}
}

//
//  ChunkTag.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/31/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

// Represents a FourCC chunk tag
struct ChunkTag : Equatable, RawRepresentable
{
	typealias RawValue = String

	var tag : [Char]

	init?(characters: [Char])
	{
		guard characters.count == 4 else { return nil }
		tag = characters
	}

	init?(rawValue: RawValue)
	{
		let fourCCStringUTF8 = rawValue.utf8
		var chars = [Char]()
		for char in fourCCStringUTF8
		{
			let charValue = UInt8(char.value)
			if let char = Char(rawValue: charValue)
			{
				chars.append(char)
			}
		}
		guard chars.count == 4 else
		{
			return nil
		}

		tag = [Char](chars)
	}

	var rawValue: RawValue
	{
		get
		{
			var stringValue = ""
			for c in tag
			{
				let scalar = UnicodeScalar(c.rawValue)
				let char = Character(scalar)
				stringValue.append(char)
			}
			return stringValue
		}
	}
}

extension ChunkTag : StringLiteralConvertible
{
	typealias StringLiteralType = RawValue
	typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
	typealias UnicodeScalarLiteralType = StringLiteralType

	init(stringLiteral value: StringLiteralType)
	{
		self = ChunkTag(someString: value)
	}

	init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType)
	{
		self = ChunkTag(someString: value)
	}

	init(unicodeScalarLiteral value: UnicodeScalarLiteralType)
	{
		self = ChunkTag(someString: value)
	}

	private init()
	{
		tag = [Char](count: 4, repeatedValue: Char.NULL)
	}

	private init(someString value: String)
	{
		self = ChunkTag(rawValue: value) ?? ChunkTag()
	}
}

func ==(lhs: ChunkTag, rhs: ChunkTag) -> Bool
{
	return lhs.tag == rhs.tag
}

extension NSInputStream
{
	func readChunkTag() -> ChunkTag?
	{
		var formTag = [Char](count: 4, repeatedValue: Char.NULL)
		if read(&formTag, maxLength: 4) == 4
		{
			return ChunkTag(characters: formTag)
		}

		return nil
	}
}


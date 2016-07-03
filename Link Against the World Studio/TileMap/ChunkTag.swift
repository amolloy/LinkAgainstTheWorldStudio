//
//  ChunkTag.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/31/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

// Represents a FourCC chunk tag
public struct ChunkTag : Equatable, RawRepresentable
{
	public typealias RawValue = String

	var tag : [Char]

	public init?(characters: [Char])
	{
		guard characters.count == 4 else { return nil }
		tag = characters
	}

	public init?(rawValue: RawValue)
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

	public var rawValue: RawValue
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
	public typealias StringLiteralType = RawValue
	public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
	public typealias UnicodeScalarLiteralType = StringLiteralType

	public init(stringLiteral value: StringLiteralType)
	{
		self = ChunkTag(someString: value)
	}

	public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType)
	{
		self = ChunkTag(someString: value)
	}

	public init(unicodeScalarLiteral value: UnicodeScalarLiteralType)
	{
		self = ChunkTag(someString: value)
	}

	private init()
	{
		tag = [Char](repeating: Char.null, count: 4)
	}

	private init(someString value: String)
	{
		self = ChunkTag(rawValue: value) ?? ChunkTag()
	}
}

public func ==(lhs: ChunkTag, rhs: ChunkTag) -> Bool
{
	return lhs.tag == rhs.tag
}

extension InputStream
{
	func readChunkTag() -> ChunkTag?
	{
		var formTag = [Char](repeating: Char.null, count: 4)
		if read(&formTag, maxLength: 4) == 4
		{
			return ChunkTag(characters: formTag)
		}

		return nil
	}
}



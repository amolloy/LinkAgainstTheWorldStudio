//
//  Char.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/31/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

enum Char : UInt8
{
	case NULL = 0x00
	case Space = 0x20
	case Zero = 0x30
	case One
	case Two
	case Three
	case Four
	case Five
	case Six
	case Seven
	case Eight
	case Nine
	case A = 0x41, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z
	case a = 0x61, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
}

extension Char : StringLiteralConvertible
{
	typealias StringLiteralType = String
	typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
	typealias UnicodeScalarLiteralType = ExtendedGraphemeClusterLiteralType

	init(someString value: String)
	{
		self = Char(rawValue: UInt8(value.utf8.first!.value)) ?? Char.NULL
	}

	init(stringLiteral value: StringLiteralType)
	{
		self = Char(someString: value)
	}

	init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType)
	{
		self = Char(someString: value)
	}

	init(unicodeScalarLiteral value: UnicodeScalarLiteralType)
	{
		self = Char(someString: value)
	}
}

extension NSInputStream
{
	func read(buffer: UnsafeMutablePointer<Char>, maxLength len: Int) -> Int
	{
		var buf = [UInt8](count: len, repeatedValue: 0)
		let readCount = read(&buf, maxLength: len)

		for i in 0..<readCount
		{
			buffer[i] = Char(rawValue: buf[i]) ?? Char.NULL
		}

		return readCount
	}
}

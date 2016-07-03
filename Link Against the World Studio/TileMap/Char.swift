//
//  Char.swift
//  TileMap
//
//  Created by Andrew Molloy on 7/31/15.
//  Copyright © 2015 Andrew Molloy. All rights reserved.
//

import Foundation

public enum Char : UInt8
{
	case null = 0x00
	case space = 0x20
	case zero = 0x30
	case one
	case two
	case three
	case four
	case five
	case six
	case seven
	case eight
	case nine
	case A = 0x41, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z
	case a = 0x61, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
}

extension Char : StringLiteralConvertible
{
	public typealias StringLiteralType = String
	public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
	public typealias UnicodeScalarLiteralType = ExtendedGraphemeClusterLiteralType

	public init(someString value: String)
	{
		self = Char(rawValue: UInt8(value.utf8.first!)) ?? Char.null
	}

	public init(stringLiteral value: StringLiteralType)
	{
		self = Char(someString: value)
	}

	public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType)
	{
		self = Char(someString: value)
	}

	public init(unicodeScalarLiteral value: UnicodeScalarLiteralType)
	{
		self = Char(someString: value)
	}
}

public extension InputStream
{
	func read(_ buffer: UnsafeMutablePointer<Char>, maxLength len: Int) -> Int
	{
		var buf = [UInt8](repeating: 0, count: len)
		let readCount = read(&buf, maxLength: len)

		for i in 0..<readCount
		{
			buffer[i] = Char(rawValue: buf[i]) ?? Char.null
		}

		return readCount
	}
}

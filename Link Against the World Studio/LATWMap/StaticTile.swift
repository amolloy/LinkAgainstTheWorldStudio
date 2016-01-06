//
//  StaticTile.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/5/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation

public class StaticTile : Tileable
{
	var index : Int

	public init(index: Int)
	{
		self.index = index
	}

	public func editorMapRepresentation() -> String
	{
		return String(index)
	}
}

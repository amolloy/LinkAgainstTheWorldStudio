//
//  TileLayer+EditorMap.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/6/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//


import Foundation
import LATWMap
import JSONCodable
import CrossPlatform

private let version = "1.0"

public extension TileLayer
{
	public func fileWrapper() -> NSFileWrapper?
	{
		let jsonData : NSData
		do
		{
			guard let jsonDict = try toJSON() as? JSONObject else
			{
				return nil
			}
			jsonData = try NSJSONSerialization.dataWithJSONObject(jsonDict, options: .PrettyPrinted)
		}
		catch let e
		{
			print("Error encoding control file for TileSet \(self): \(e)")
			return nil
		}

		let controlFile = NSFileWrapper(regularFileWithContents: jsonData)

		return NSFileWrapper(directoryWithFileWrappers: ["Info.json": controlFile])
	}

	public convenience init?(fileWrapper: NSFileWrapper) throws
	{
		guard let fileWrappers = fileWrapper.fileWrappers,
			  let controlFile = fileWrappers["Info.json"],
			  let jsonData = controlFile.regularFileContents else { return nil }

		let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(rawValue: 0))
		self.init(JSONDictionary: jsonDict as! JSONObject)
	}
}

private let versionKey = "version"
private let nameKey = "name"
private let tileSetKey = "tileSet"
private let terrainsKey = "terrains"
private let layerDataKey = "layerData"
private let zIndexKey = "zIndex"

extension TileLayer : JSONEncodable
{
	public func toJSON() throws -> AnyObject
	{
		return try JSONEncoder.create({ (encoder) -> Void in
			try encoder.encode(version, key: versionKey)
			try encoder.encode(name, key: nameKey)
			if let tileSet = tileSet
			{
				try encoder.encode(tileSetKey, key: tileSet.name)
			}
			// TODO Add terrains support
			try encoder.encode(zIndex, key: zIndexKey)

			let layerData = tiles.flatMap { row in
				return row.reduce(String(), combine: { (accum, tile : Tileable) -> String in
					return accum + "," + tile.editorMapRepresentation()
				})
			}

			try encoder.encode(layerData, key: layerDataKey)
		})
	}
}

extension TileLayer : JSONDecodable
{
	public convenience init?(JSONDictionary: JSONObject)
	{
		let decoder = JSONDecoder(object: JSONDictionary)
		do
		{
			let name : String = try decoder.decode(nameKey)
			let jsonVersion : String = try decoder.decode(versionKey)
			if jsonVersion.compare(version, options: .NumericSearch, range: nil, locale: nil) == .OrderedDescending
			{
				print("TileSet \(name) too new (got \(jsonVersion) expected \(version)). Going to try to load anyways.")
			}

			self.init(name: name, tiles: [[Tileable]]())
		}
		catch
		{
			return nil
		}
	}
}

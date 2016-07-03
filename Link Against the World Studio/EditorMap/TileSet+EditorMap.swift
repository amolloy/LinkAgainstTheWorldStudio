//
//  TileSet+EditorMap.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/4/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation
import LATWMap
import JSONCodable
import CrossPlatform

private let version = "1.0"

public extension TileSet
{
	public func fileWrapper() -> FileWrapper?
	{
		let jsonData : Data
		do
		{
			guard let jsonDict = try toJSON() as? JSONObject else
			{
				return nil
			}
			jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
		}
		catch let e
		{
			print("Error encoding control file for TileSet \(self): \(e)")
			return nil
		}

		let controlFile = FileWrapper(regularFileWithContents: jsonData)
		var imageFile : FileWrapper? = nil
		if let image = image
		{
			if let imageData = image.tiffRepresentation
			{
				imageFile = FileWrapper(regularFileWithContents: imageData)
			}
		}

		var wrapperDict = ["Info.json": controlFile]
		if let imageFile = imageFile
		{
			wrapperDict[imageName] = imageFile
		}

		return FileWrapper(directoryWithFileWrappers: wrapperDict)
	}

	public convenience init?(fileWrapper: FileWrapper) throws
	{
		guard let fileWrappers = fileWrapper.fileWrappers else { return nil }
		guard let controlFile = fileWrappers["Info.json"] else { return nil }
		guard let jsonData = controlFile.regularFileContents else { return nil }
		let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0))
		self.init(JSONDictionary: jsonDict as! JSONObject)

		guard let imageWrapper = fileWrappers[imageName] else { return nil }
		guard let imageData = imageWrapper.regularFileContents else { return nil }
		guard let image = CrossPlatform.Image(data: imageData) else { return nil }

		self.image = image
	}
}

private let versionKey = "version"
private let nameKey = "name"
private let imageNameKey = "imageName"
private let tileCountKey = "tileCount"
private let tileWidthKey = "tileWidth"
private let tileHeightKey = "tileHeight"

extension TileSet : JSONEncodable
{
	public func toJSON() throws -> AnyObject
	{
		return try JSONEncoder.create({ (encoder) -> Void in
			try encoder.encode(version, key: versionKey)
			try encoder.encode(imageName, key: imageNameKey)
			try encoder.encode(name, key: nameKey)
			try encoder.encode(tileCount, key: tileCountKey)
			try encoder.encode(tileWidth, key: tileWidthKey)
			try encoder.encode(tileHeight, key: tileHeightKey)
		})
	}
}

extension TileSet : JSONDecodable
{
	public convenience init?(JSONDictionary: JSONObject)
	{
		let decoder = JSONDecoder(object: JSONDictionary)
		do
		{
			let name : String = try decoder.decode(nameKey)
			let jsonVersion : String = try decoder.decode(versionKey)
			if jsonVersion.compare(version, options: .numericSearch, range: nil, locale: nil) == .orderedDescending
			{
				print("TileSet \(name) too new (got \(jsonVersion) expected \(version)). Going to try to load anyways.")
			}

			self.init(image: nil,
				imageName: try decoder.decode(imageNameKey),
				name: name,
				tileCount: try decoder.decode(tileCountKey),
				tileWidth: try decoder.decode(tileWidthKey),
				tileHeight: try decoder.decode(tileHeightKey))
		}
		catch
		{
			return nil
		}
	}
}

typealias EditorMapTileSetLoader = TileSet
extension EditorMapTileSetLoader : EditorMapSegment
{
	static func loadSegmentFromFileWrapper(_ fileWrapper: FileWrapper, owner: Map) throws
	{
		if let tileSet = try TileSet(fileWrapper: fileWrapper)
		{
			owner.addTileSet(tileSet)
		}

	}

	static func segmentDependencies() -> [EditorMapSegment.Type]
	{
		return []
	}

	static func segmentExtension() -> String
	{
		return "tileset"
	}
}

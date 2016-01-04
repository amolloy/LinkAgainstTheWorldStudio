//
//  TileSet+EditorMap.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/4/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation
import Map
import JSONCodable
import CrossPlatform

public extension TileSet
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
		var imageFile : NSFileWrapper? = nil
		if let image = image
		{
			if let imageData = image.TIFFRepresentation
			{
				imageFile = NSFileWrapper(regularFileWithContents: imageData)
			}
		}

		var wrapperDict = ["Info.json": controlFile]
		if let imageFile = imageFile
		{
			wrapperDict[imageName] = imageFile
		}

		return NSFileWrapper(directoryWithFileWrappers: wrapperDict)
	}

	public convenience init?(fileWrapper: NSFileWrapper) throws
	{
		guard let fileWrappers = fileWrapper.fileWrappers else { return nil }
		guard let controlFile = fileWrappers["Info.json"] else { return nil }
		guard let jsonData = controlFile.regularFileContents else { return nil }
		let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(rawValue: 0))
		self.init(JSONDictionary: jsonDict as! JSONObject)

		guard let imageWrapper = fileWrappers[imageName] else { return nil }
		guard let imageData = imageWrapper.regularFileContents else { return nil }
		guard let image = Image(data: imageData) else { return nil }

		self.image = image
	}
}

let nameKey = "name"
let imageNameKey = "imageName"
let tileCountKey = "tileCount"
let tileWidthKey = "tileWidth"
let tileHeightKey = "tileHeight"

extension TileSet : JSONEncodable
{
	public func toJSON() throws -> AnyObject
	{
		return try JSONEncoder.create({ (encoder) -> Void in
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
			self.init(image: nil,
				imageName: try decoder.decode(imageNameKey),
				name: try decoder.decode(nameKey),
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

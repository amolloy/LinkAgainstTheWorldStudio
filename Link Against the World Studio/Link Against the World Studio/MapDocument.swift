//
//  MapDocument.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/2/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Cocoa
import TileMap
import LATWMap
import EditorMap

class MapDocument: NSDocument {

	let standardFileType = "com.amolloy.latwmap"
	var map : Map?
	var documentFileWrapper : NSFileWrapper?

	override init()
	{
	    super.init()
		map = nil
	}

	override func windowControllerDidLoadNib(aController: NSWindowController)
	{
		super.windowControllerDidLoadNib(aController)
		// Add any code here that needs to be executed once the windowController has loaded the document's window.
	}

	override class func autosavesInPlace() -> Bool
	{
		return true
	}

	override func makeWindowControllers()
	{
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
		self.addWindowController(windowController)
	}

	override func fileWrapperOfType(typeName: String) throws -> NSFileWrapper
	{
		guard let map = map else { return NSFileWrapper() }

		if self.documentFileWrapper == nil
		{
			documentFileWrapper = NSFileWrapper(directoryWithFileWrappers: [String: NSFileWrapper]())
		}

		guard let documentFileWrapper = documentFileWrapper else { return NSFileWrapper() }

		for tileSetName : NSString in map.tileSets.keys
		{
			let wrapperName = tileSetName.stringByAppendingPathExtension("tileset") ?? "" as String

			if let fileWrapper = map.tileSets[tileSetName as String]?.fileWrapper()
			{
				fileWrapper.preferredFilename = wrapperName
				documentFileWrapper.addFileWrapper(fileWrapper)
			}
		}

		for tileLayer in map.tileLayers
		{
			if let fileWrapper = tileLayer.fileWrapper()
			{
				fileWrapper.preferredFilename = (tileLayer.name as NSString).stringByAppendingPathExtension("tilelayer")
				documentFileWrapper.addFileWrapper(fileWrapper)
			}
		}

		return documentFileWrapper
	}

	override func readFromFileWrapper(fileWrapper: NSFileWrapper, ofType typeName: String) throws
	{
		if (NSWorkspace.sharedWorkspace().type("com.amolloy.tilemap", conformsToType: typeName))
		{
			// import...
			self.fileURL = nil
			self.fileType = standardFileType

			guard let fileContents = fileWrapper.regularFileContents else { return }
			let tileMapInputStream = NSInputStream(data: fileContents)
			guard let tileMap = TileMap(inputStream: tileMapInputStream) else { return }
			try tileMap.open()
			try tileMap.loadChunks()

			map = try Map(tileMap: tileMap)
		}
		else if (NSWorkspace.sharedWorkspace().type(standardFileType, conformsToType: typeName))
		{
			map = Map()
			guard let map = map else { return }

			// TODO error handling
			guard let fileWrappers = fileWrapper.fileWrappers else { return }
			for key in fileWrappers.keys
			{
				if let wrapper = fileWrappers[key]
				{
					let ext = (key as NSString).pathExtension.lowercaseString as String
					switch ext
					{
					case "tileset":
						if let tileset = try TileSet(fileWrapper: wrapper)
						{
							map.addTileSet(tileset)
						}
						break
					default:
						print("Unknown file in LATW Map: \(key)")
						break
					}
				}
			}
		}
	}

	override class func canConcurrentlyReadDocumentsOfType(typename: String) -> Bool
	{
		return true
	}
}


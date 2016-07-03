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

class MapDocument: NSDocument
{
	let standardFileType = "com.amolloy.latwmap"
	var map : Map?
	var documentFileWrapper : FileWrapper?

	override init()
	{
	    super.init()
		map = nil
	}

	override func windowControllerDidLoadNib(_ aController: NSWindowController)
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
		let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
		self.addWindowController(windowController)
	}

	override func fileWrapper(ofType typeName: String) throws -> FileWrapper
	{
		guard let map = map else { return FileWrapper() }

		if self.documentFileWrapper == nil
		{
			documentFileWrapper = FileWrapper(directoryWithFileWrappers: [String: FileWrapper]())
		}

		guard let documentFileWrapper = documentFileWrapper else { return FileWrapper() }

		for tileSetName : NSString in map.tileSets.keys
		{
			let wrapperName = tileSetName.appendingPathExtension("tileset") ?? "" as String

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
				fileWrapper.preferredFilename = (tileLayer.name as NSString).appendingPathExtension("tilelayer")
				documentFileWrapper.addFileWrapper(fileWrapper)
			}
		}

		return documentFileWrapper
	}

	override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws
	{
		if (NSWorkspace.shared().type("com.amolloy.tilemap", conformsToType: typeName))
		{
			// import...
			self.fileURL = nil
			self.fileType = standardFileType

			guard let fileContents = fileWrapper.regularFileContents else { return }
			let tileMapInputStream = InputStream(data: fileContents)
			guard let tileMap = TileMap(inputStream: tileMapInputStream) else { return }
			_ = try tileMap.open()
			try tileMap.loadChunks()

			map = try Map(tileMap: tileMap)
		}
		else if (NSWorkspace.shared().type(standardFileType, conformsToType: typeName))
		{
			map = try mapFromFileWrapper(fileWrapper)
		}
	}

	override class func canConcurrentlyReadDocuments(ofType typename: String) -> Bool
	{
		return true
	}
}


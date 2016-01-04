//
//  MapDocument.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/2/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Cocoa
import TileMap
import Map

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
		if self.documentFileWrapper == nil
		{
			documentFileWrapper = NSFileWrapper(directoryWithFileWrappers: [String: NSFileWrapper]())
		}

		guard let documentFileWrapper = documentFileWrapper else { return NSFileWrapper() }
//		let fileWrappers = documentFileWrapper.fileWrappers

		return documentFileWrapper
	}

	override func readFromFileWrapper(fileWrapper: NSFileWrapper, ofType typeName: String) throws
	{

	}

	override func readFromData(data: NSData, ofType typeName: String) throws
	{
		if (NSWorkspace.sharedWorkspace().type("com.amolloy.tilemap", conformsToType: typeName))
		{
			// import...
			self.fileURL = nil
			self.fileType = standardFileType

			let tileMapInputStream = NSInputStream(data: data)
			guard let tileMap = TileMap(inputStream: tileMapInputStream) else { return }
			try tileMap.open()
			try tileMap.loadChunks()

			map = try Map(tileMap: tileMap)
		}
		else if (NSWorkspace.sharedWorkspace().type(standardFileType, conformsToType: typeName))
		{

		}
	}

	override class func canConcurrentlyReadDocumentsOfType(typename: String) -> Bool
	{
		return true
	}
}


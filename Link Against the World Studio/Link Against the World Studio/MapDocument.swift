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

	override init()
	{
	    super.init()
		// Add your subclass-specific initialization here.
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


	override func dataOfType(typeName: String) throws -> NSData
	{
		// Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
		// You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
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

			// TEMP
			let _ = try Map(tileMap: tileMap)
		}
		else if (NSWorkspace.sharedWorkspace().type(standardFileType, conformsToType: typeName))
		{

		}
	}
}


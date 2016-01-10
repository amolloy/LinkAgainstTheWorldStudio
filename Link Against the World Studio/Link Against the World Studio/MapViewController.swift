//
//  MapViewController.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/10/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Cocoa
import SpriteKit
import LATWMapSKRenderer

class MapViewController: NSViewController {

	var skView : SKView? = nil

	override func viewDidLoad()
	{
		super.viewDidLoad()

		if let scene = MapScene(fileNamed:"GameScene")
		{
			let skView = SKView(frame: view.bounds)
			skView.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(skView)
			skView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
			skView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
			skView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
			skView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true

			scene.scaleMode = .AspectFill

			skView.presentScene(scene)

			skView.ignoresSiblingOrder = true

			skView.showsFPS = true
			skView.showsNodeCount = true

			self.skView = skView
		}
	}

	var mapDocument : MapDocument? {
		get {
			guard let window = self.view.window else { return nil }
			return NSDocumentController.sharedDocumentController().documentForWindow(window) as? MapDocument
		}
	}

	override func viewWillAppear()
	{
		super.viewWillAppear()

		guard let mapDocument = mapDocument,
			  let map = mapDocument.map,
			  let skView = skView,
			  let scene = skView.scene,
		      let mapNode = TileMapNode(map: map) else
		{
			return
		}

		scene.addChild(mapNode)
	}
}


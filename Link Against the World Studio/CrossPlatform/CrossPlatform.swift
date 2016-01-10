//
//  CrossPlatform.swift
//  LATWMap
//
//  Created by Andrew Molloy on 1/2/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

#if os(iOS)
	import UIKit
	public typealias Responder = UIResponder
	public typealias Image = UIImage
	public typealias Color = UIColor

	public extension UIImage
	{
		public var cgImage: CGImage?
		{
			get
			{
				return CGImage
			}
		}
	}

#elseif os(OSX)
	import AppKit
	public typealias Responder = NSResponder
	public typealias Image = NSImage
	public typealias Color = NSColor

	public extension Image
	{
		public var cgImage: CGImage?
		{
			get
			{
				return CGImageForProposedRect(nil, context: nil, hints: nil)
			}
		}
	}
#endif

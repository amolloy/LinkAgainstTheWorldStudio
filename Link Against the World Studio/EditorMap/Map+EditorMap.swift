//
//  Map+EditorMap.swift
//  Link Against the World Studio
//
//  Created by Andrew Molloy on 1/7/16.
//  Copyright © 2016 Andy Molloy. All rights reserved.
//

import Foundation
import LATWMap
import JSONCodable
import CrossPlatform

private let version = "1.0"

protocol EditorMapSegment
{
	static func loadSegmentFromFileWrapper(_ fileWrapper: FileWrapper, owner: Map) throws
	static func segmentDependencies() -> [EditorMapSegment.Type]
	static func segmentExtension() -> String
}

private let segmentLoaders : [EditorMapSegment.Type] = [TileSet.self, TileLayer.self]

func dependencySortSegments(_ segments: [FileWrapper], loaderMap:[String: EditorMapSegment.Type]) -> [FileWrapper]
{
	print("sorting")
	return segments.sorted(isOrderedBefore: { (a, b) -> Bool in
		var isOrderedBefore = true
		print("Getting extensions and loaders")
		if let aExtension = (a.filename as NSString?)?.pathExtension,
		   let aLoader = loaderMap[aExtension],
		   let bExtension = (b.filename as NSString?)?.pathExtension,
		   let bLoader = loaderMap[bExtension]
		{
			print("Checking if bLoader's dependencies contains aLoader")
			print("bLoader (\(bLoader)) depends on \(bLoader.segmentDependencies())")
			print("aLoader is a \(aLoader)")
			isOrderedBefore = bLoader.segmentDependencies().contains() { e in
				let itContains = e == aLoader
				print("\(aLoader) contains \(bLoader) ? \(itContains)")
				return itContains
			}
		}
		return isOrderedBefore
	})
}

public func mapFromFileWrapper(_ fileWrapper: FileWrapper) throws -> Map?
{
	let map = Map()

	let loaderMap = segmentLoaders.reduce([String: EditorMapSegment.Type]()) { (dictionary, e) in
		dictionary[e.segmentExtension()] = e
		return dictionary
	}

	guard let fileWrappers = fileWrapper.fileWrappers else { return nil }
	let sortedWrappers = dependencySortSegments(Array(fileWrappers.values), loaderMap: loaderMap)

	for wrapper in sortedWrappers
	{
		if let wrapperExtension = (wrapper.filename as NSString?)?.pathExtension,
		   let loader = loaderMap[wrapperExtension]
		{
			try loader.loadSegmentFromFileWrapper(wrapper, owner: map)
		}
	}

	return map
}

//
//  JSONDecodable.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// Decoding Errors

import Foundation

public enum JSONDecodableError: ErrorProtocol, CustomStringConvertible {
    case missingTypeError(
        key: String
    )
    case incompatibleTypeError(
        key: String,
        elementType: Any.Type,
        expectedType: Any.Type
    )
    case arrayTypeExpectedError(
        key: String,
        elementType: Any.Type
    )
    case dictionaryTypeExpectedError(
        key: String,
        elementType: Any.Type
    )
    case transformerFailedError(
        key: String
    )
    
    public var description: String {
        switch self {
        case let .missingTypeError(key: key):
            return "JSONDecodableError: Missing value for key \(key)"
        case let .incompatibleTypeError(key: key, elementType: elementType, expectedType: expectedType):
            return "JSONDecodableError: Incompatible type for key \(key); Got \(elementType) instead of \(expectedType)"
        case let .arrayTypeExpectedError(key: key, elementType: elementType):
            return "JSONDecodableError: Got \(elementType) instead of an array for key \(key)"
        case let .dictionaryTypeExpectedError(key: key, elementType: elementType):
            return "JSONDecodableError: Got \(elementType) instead of a dictionary for key \(key)"
        case let .transformerFailedError(key: key):
            return "JSONDecodableError: Transformer failed for key \(key)"
        }
    }
}

// Dictionary -> Struct

public protocol JSONDecodable {
    init(object: JSONObject) throws
}

public extension JSONDecodable {
    public init?(optional: JSONObject) {
        do {
            try self.init(object: optional)
        } catch {
            return nil
        }
    }
}

public extension Array where Element: JSONDecodable {
    init(JSONArray: [AnyObject]) throws {
        self.init(try JSONArray.flatMap {
            guard let json = $0 as? [String : AnyObject] else {
                throw JSONDecodableError.dictionaryTypeExpectedError(key: "n/a", elementType: $0.dynamicType)
            }
            return try Element(object: json)
            })
    }
}

// JSONDecoder - provides utility methods for decoding

public class JSONDecoder {
    let object: JSONObject
    
    public init(object: JSONObject) {
        self.object = object
    }
    
    private func get(_ key: String) -> AnyObject? {
        let keys = key.components(separatedBy: ".")
        
        let result = keys.reduce(object as AnyObject?) {
            value, key in
            
            guard let dict = value as? [String: AnyObject] else {
                return nil
            }
            
            return dict[key]
        }
        return (result ?? object[key]).flatMap{$0 is NSNull ? nil : $0}
    }
    
    // JSONCompatible
    public func decode<Compatible: JSONCompatible>(_ key: String) throws -> Compatible {
        guard let value = get(key) else {
            throw JSONDecodableError.missingTypeError(key: key)
        }
        guard let compatible = value as? Compatible else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: Compatible.self)
        }
        return compatible
    }
    
    // JSONCompatible?
    public func decode<Compatible: JSONCompatible>(_ key: String) throws -> Compatible? {
        return (get(key) ?? object[key]) as? Compatible
    }
    
    // JSONDecodable
    public func decode<Decodable: JSONDecodable>(_ key: String) throws -> Decodable {
        guard let value = get(key) else {
            throw JSONDecodableError.missingTypeError(key: key)
        }
        guard let object = value as? JSONObject else {
            throw JSONDecodableError.dictionaryTypeExpectedError(key: key, elementType: value.dynamicType)
        }
        return try Decodable(object: object)
    }
    
    // JSONDecodable?
    public func decode<Decodable: JSONDecodable>(_ key: String) throws -> Decodable? {
        guard let value = get(key) else {
            return nil
        }
        guard let object = value as? JSONObject else {
            throw JSONDecodableError.dictionaryTypeExpectedError(key: key, elementType: value.dynamicType)
        }
        return try Decodable(object: object)
    }
    
    // Enum
    public func decode<Enum: RawRepresentable>(_ key: String) throws -> Enum {
        guard let value = get(key) else {
            throw JSONDecodableError.missingTypeError(key: key)
        }
        guard let raw = value as? Enum.RawValue else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: Enum.RawValue.self)
        }
        guard let result = Enum(rawValue: raw) else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: Enum.RawValue.self, expectedType: Enum.self)
        }
        return result
    }
    
    // Enum?
    public func decode<Enum: RawRepresentable>(_ key: String) throws -> Enum? {
        guard let value = get(key) else {
            return nil
        }
        guard let raw = value as? Enum.RawValue else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: Enum.RawValue.self)
        }
        guard let result = Enum(rawValue: raw) else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: Enum.RawValue.self, expectedType: Enum.self)
        }
        return result
    }
    
    // [JSONCompatible]
    public func decode<Element: JSONCompatible>(_ key: String) throws -> [Element] {
        guard let value = get(key) else {
            throw JSONDecodableError.missingTypeError(key: key)
        }
        guard let array = value as? [Element] else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: [Element].self)
        }
        return array
    }
    
    // [JSONCompatible]?
    public func decode<Element: JSONCompatible>(_ key: String) throws -> [Element]? {
        guard let value = get(key) else {
            return nil
        }
        guard let array = value as? [Element] else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: [Element].self)
        }
        return array
    }
    
    // [JSONDecodable]
    public func decode<Element: JSONDecodable>(_ key: String) throws -> [Element] {
        guard let value = get(key) else {
            return []
        }
        guard let array = value as? [JSONObject] else {
            throw JSONDecodableError.arrayTypeExpectedError(key: key, elementType: value.dynamicType)
        }
        return try array.flatMap { try Element(object: $0)}
    }
    
    // [JSONDecodable]?
    public func decode<Element: JSONDecodable>(_ key: String) throws -> [Element]? {
        guard let value = get(key) else {
            return nil
        }
        guard let array = value as? [JSONObject] else {
            throw JSONDecodableError.arrayTypeExpectedError(key: key, elementType: value.dynamicType)
        }
        return try array.flatMap { try Element(object: $0)}
    }
    
    // [Enum]
    public func decode<Enum: RawRepresentable>(_ key: String) throws -> [Enum] {
        guard let value = get(key) else {
            return []
        }
        guard let array = value as? [Enum.RawValue] else {
            throw JSONDecodableError.arrayTypeExpectedError(key: key, elementType: value.dynamicType)
        }
        return array.flatMap { Enum(rawValue: $0) }
    }
    
    // [Enum]?
    public func decode<Enum: RawRepresentable>(_ key: String) throws -> [Enum]? {
        guard let value = get(key) else {
            return nil
        }
        guard let array = value as? [Enum.RawValue] else {
            throw JSONDecodableError.arrayTypeExpectedError(key: key, elementType: value.dynamicType)
        }
        return array.flatMap { Enum(rawValue: $0) }
    }
    
    // [String:JSONCompatible]
    public func decode<Value: JSONCompatible>(_ key: String) throws -> [String: Value] {
        guard let value = get(key) else {
            throw JSONDecodableError.missingTypeError(key: key)
        }
        guard let dictionary = value as? [String: Value] else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: [String: Value].self)
        }
        return dictionary
    }
    
    // [String:JSONCompatible]?
    public func decode<Value: JSONCompatible>(_ key: String) throws -> [String: Value]? {
        guard let value = get(key) else {
            return nil
        }
        guard let dictionary = value as? [String: Value] else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: [String: Value].self)
        }
        return dictionary
    }
    
    // JSONTransformable
    public func decode<EncodedType, DecodedType>(_ key: String, transformer: JSONTransformer<EncodedType, DecodedType>) throws -> DecodedType {
        guard let value = get(key) else {
            throw JSONDecodableError.missingTypeError(key: key)
        }
        guard let actual = value as? EncodedType else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: EncodedType.self)
        }
        guard let result = transformer.decoding(actual) else {
            throw JSONDecodableError.transformerFailedError(key: key)
        }
        return result
    }
    
    // JSONTransformable?
    public func decode<EncodedType, DecodedType>(_ key: String, transformer: JSONTransformer<EncodedType, DecodedType>) throws -> DecodedType? {
        guard let value = get(key) else {
            return nil
        }
        guard let actual = value as? EncodedType else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: EncodedType.self)
        }
        guard let result = transformer.decoding(actual) else {
            throw JSONDecodableError.transformerFailedError(key: key)
        }
        return result
    }
}
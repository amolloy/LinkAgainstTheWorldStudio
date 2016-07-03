//
//  JSONEncodable.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// Encoding Errors

public enum JSONEncodableError: ErrorProtocol, CustomStringConvertible {
    case incompatibleTypeError(
        elementType: Any.Type
    )
    case arrayIncompatibleTypeError(
        elementType: Any.Type
    )
    case dictionaryIncompatibleTypeError(
        elementType: Any.Type
    )
    case childIncompatibleTypeError(
        key: String,
        elementType: Any.Type
    )
    case transformerFailedError(
        key: String
    )
    
    public var description: String {
        switch self {
        case let .incompatibleTypeError(elementType: elementType):
            return "JSONEncodableError: Incompatible type \(elementType)"
        case let .arrayIncompatibleTypeError(elementType: elementType):
            return "JSONEncodableError: Got an array of incompatible type \(elementType)"
        case let .dictionaryIncompatibleTypeError(elementType: elementType):
            return "JSONEncodableError: Got an dictionary of incompatible type \(elementType)"
        case let .childIncompatibleTypeError(key: key, elementType: elementType):
            return "JSONEncodableError: Got incompatible type \(elementType) for key \(key)"
        case let .transformerFailedError(key: key):
            return "JSONEncodableError: Transformer failed for key \(key)"
        }
    }
}

// Struct -> Dictionary

public protocol JSONEncodable {
    func toJSON() throws -> AnyObject
}

public extension JSONEncodable {
    func toJSON() throws -> AnyObject {
        let mirror = Mirror(reflecting: self)
        
        guard let style = mirror.displayStyle where style == .struct || style == .class else {
            throw JSONEncodableError.incompatibleTypeError(elementType: self.dynamicType)
        }
        
        return try JSONEncoder.create(setup: { (encoder) -> Void in
            // loop through all properties (instance variables)
            for (labelMaybe, valueMaybe) in mirror.children {
                guard let label = labelMaybe else {
                    continue
                }
                
                let value: Any
                
                // unwrap optionals
                if let v = valueMaybe as? JSONOptional {
                    guard let unwrapped = v.wrapped else {
                        continue
                    }
                    value = unwrapped
                }
                else {
                    value = valueMaybe
                }
                
                switch (value) {
                case let value as JSONEncodable:
                    try encoder.encode(value, key: label)
                case let value as JSONArray:
                    try encoder.encode(value, key: label)
                case let value as JSONDictionary:
                    try encoder.encode(value, key: label)
                default:
                    throw JSONEncodableError.childIncompatibleTypeError(key: label, elementType: value.dynamicType)
                }
            }
        })
    }
}

public extension Array {//where Element: JSONEncodable {
    private var wrapped: [Any] { return self.map{$0} }
    
    public func toJSON() throws -> AnyObject {
        var results: [AnyObject] = []
        for item in self.wrapped {
            if let item = item as? JSONEncodable {
                results.append(try item.toJSON())
            }
            else {
                throw JSONEncodableError.arrayIncompatibleTypeError(elementType: item.dynamicType)
            }
        }
        return results
    }
}

// Dictionary convenience methods

public extension Dictionary {//where Key: String, Value: JSONEncodable {
    public func toJSON() throws -> AnyObject {
        var result: [String: AnyObject] = [:]
        for (k, item) in self {
            if let item = item as? JSONEncodable {
                result[String(k)] = try item.toJSON()
            }
            else {
                throw JSONEncodableError.dictionaryIncompatibleTypeError(elementType: item.dynamicType)
            }
        }
        return result
    }
}

// JSONEncoder - provides utility methods for encoding

public class JSONEncoder {
    var object = JSONObject()
    
    public static func create( setup: @noescape(encoder: JSONEncoder) throws -> Void) rethrows -> JSONObject {
        let encoder = JSONEncoder()
        try setup(encoder: encoder)
        return encoder.object
    }
    
    /* 
    Note:
    There is some duplication because methods with generic constraints need to
    take a concrete type conforming to the constraint are unable to take a parameter
    typed to the protocol. Hence we need non-generic versions so we can cast from 
    Any to JSONEncodable in the default implementation for toJSON().
    */
    
    // JSONEncodable
    public func encode<Encodable: JSONEncodable>(_ value: Encodable, key: String) throws {
        let result = try value.toJSON()
        object[key] = result
    }
    private func encode(_ value: JSONEncodable, key: String) throws {
        let result = try value.toJSON()
        object[key] = result
    }

    // JSONEncodable?
    public func encode<Encodable: JSONEncodable>(_ value: Encodable?, key: String) throws {
        guard let actual = value else {
            return
        }
        let result = try actual.toJSON()
        object[key] = result
    }

    // Enum
    public func encode<Enum: RawRepresentable>(_ value: Enum, key: String) throws {
        guard let compatible = value.rawValue as? JSONCompatible else {
            return
        }
        let result = try compatible.toJSON()
        object[key] = result
    }
    
    // Enum?
    public func encode<Enum: RawRepresentable>(_ value: Enum?, key: String) throws {
        guard let actual = value else {
            return
        }
        guard let compatible = actual.rawValue as? JSONCompatible else {
            return
        }
        let result = try compatible.toJSON()
        object[key] = result
    }
    
    // [JSONEncodable]
    public func encode<Encodable: JSONEncodable>(_ array: [Encodable], key: String) throws {
        guard array.count > 0 else {
            return
        }
        let result = try array.toJSON()
        object[key] = result
    }
    public func encode(_ array: [JSONEncodable], key: String) throws {
        guard array.count > 0 else {
            return
        }
        let result = try array.toJSON()
        object[key] = result
    }
    private func encode(_ array: JSONArray, key: String) throws {
        guard array.count > 0 && array.elementsAreJSONEncodable() else {
            return
        }
        let encodable = array.elementsMadeJSONEncodable()
        let result = try encodable.toJSON()
        object[key] = result
    }
    
    // [JSONEncodable]?
    public func encode<Encodable: JSONEncodable>(_ value: [Encodable]?, key: String) throws {
        guard let actual = value else {
            return
        }
        guard actual.count > 0 else {
            return
        }
        let result = try actual.toJSON()
        object[key] = result
    }
    
    // [Enum]
    public func encode<Enum: RawRepresentable>(_ value: [Enum], key: String) throws {
        guard value.count > 0 else {
            return
        }
        let result = try value.flatMap {
            try ($0.rawValue as? JSONCompatible)?.toJSON()
        }
        object[key] = result
    }
    
    // [Enum]?
    public func encode<Enum: RawRepresentable>(_ value: [Enum]?, key: String) throws {
        guard let actual = value else {
            return
        }
        guard actual.count > 0 else {
            return
        }
        let result = try actual.flatMap {
            try ($0.rawValue as? JSONCompatible)?.toJSON()
        }
        object[key] = result
    }
    
    // [String:JSONEncodable]
    public func encode<Encodable: JSONEncodable>(_ dictionary: [String:Encodable], key: String) throws {
        guard dictionary.count > 0 else {
            return
        }
        let result = try dictionary.toJSON()
        object[key] = result
    }
    public func encode(_ dictionary: [String:JSONEncodable], key: String) throws {
        guard dictionary.count > 0 else {
            return
        }
        let result = try dictionary.toJSON()
        object[key] = result
    }
    private func encode(_ dictionary: JSONDictionary, key: String) throws {
        guard dictionary.count > 0 && dictionary.valuesAreJSONEncodable() else {
            return
        }
        let encodable = dictionary.valuesMadeJSONEncodable()
        let result = try encodable.toJSON()
        object[key] = result
    }
    
    // [String:JSONEncodable]?
    public func encode<Encodable: JSONEncodable>(_ value: [String:Encodable]?, key: String) throws {
        guard let actual = value else {
            return
        }
        guard actual.count > 0 else {
            return
        }
        let result = try actual.toJSON()
        object[key] = result
    }
    
    // JSONTransformable
    public func encode<EncodedType, DecodedType>(_ value: DecodedType, key: String, transformer: JSONTransformer<EncodedType, DecodedType>) throws {
        guard let result = transformer.encoding(value) else {
            throw JSONEncodableError.transformerFailedError(key: key)
        }
        object[key] = (result as! AnyObject)
    }
    
    // JSONTransformable?
    public func encode<EncodedType, DecodedType>(_ value: DecodedType?, key: String, transformer: JSONTransformer<EncodedType, DecodedType>) throws {
        guard let actual = value else {
            return
        }
        guard let result = transformer.encoding(actual) else {
            return
        }
        object[key] = (result as! AnyObject)
    }
}
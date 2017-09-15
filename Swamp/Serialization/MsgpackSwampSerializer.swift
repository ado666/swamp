//
//  MsgpackSwampSerializer.swift
//  Swamp
//

#if MSGPACK_SUPPORT

import Foundation
import MessagePack

open class MsgpackSwampSerializer: SwampSerializer {

    public init() {}
    
    open func anyToMPValue(anyVal : Any) -> MessagePackValue? {
        
        switch(anyVal) {
            
        case is Bool:
            return MessagePackValue(anyVal as! Bool)
        case is Int:
            return MessagePackValue(anyVal as! Int)
        case is Int8:
            return MessagePackValue(anyVal as! Int8)
        case is Int16:
            return MessagePackValue(anyVal as! Int16)
        case is Int32:
            return MessagePackValue(anyVal as! Int32)
        case is Int64:
            return MessagePackValue(anyVal as! Int64)
        case is UInt:
            return MessagePackValue(anyVal as! UInt)
        case is UInt8:
            return MessagePackValue(anyVal as! UInt8)
        case is UInt16:
            return MessagePackValue(anyVal as! UInt16)
        case is UInt32:
            return MessagePackValue(anyVal as! UInt32)
        case is UInt64:
            return MessagePackValue(anyVal as! UInt64)
        case is Float:
            return MessagePackValue(anyVal as! Float)
        case is Double:
            return MessagePackValue(anyVal as! Double)
        case is String:
            return MessagePackValue(anyVal as! String)
        case is Data:
            return MessagePackValue(anyVal as! Data)
        case is Array<Any>:
            let arrayVal = anyVal as! Array<Any>
            var mpArray = Array<MessagePackValue>()
            for value in arrayVal {
                if let mpValue = anyToMPValue(anyVal: value) {
                    mpArray.append(mpValue)
                } else {
                    print("Failed to convert '\(value)' to mpValue")
                }
            }
            return MessagePackValue(mpArray)
        case is Dictionary<String, Any>:
            let dictVal = anyVal as! Dictionary<String, Any>
            var mpDict = [MessagePackValue : MessagePackValue]()
            for (key,value) in dictVal {
                let mpKey = MessagePackValue(key)
                if let mpValue = anyToMPValue(anyVal: value) {
                    mpDict[mpKey] = mpValue
                } else {
                    print("Failed to convert '\(value)'")
                }
            }
            return MessagePackValue(mpDict)
            
        default:
            print("Unknown type for `\(anyVal)` -- cannot convert to mpValue")
            return nil;
        }
    }
    
    open func mpValueToAny(_ mpValue : MessagePackValue) -> Any? {
        switch(mpValue) {
            
        case .bool:
            return mpValue.boolValue
        case .int:
            return mpValue.integerValue
        case .uint:
            return mpValue.unsignedIntegerValue
        case .float:
            return mpValue.floatValue
        case .double:
            return mpValue.doubleValue
        case .string:
            return mpValue.stringValue
        case .binary:
            return mpValue.dataValue
        case .array:
            var array = [Any]()
            if let mpArray = mpValue.arrayValue {
                for mpSubVal in mpArray {
                    if let subVal = mpValueToAny(mpSubVal) {
                        array.append(subVal)
                    }
                }
            }
            return array
        case .map:
            var dict = [String : Any]()
            if let mpDict = mpValue.dictionaryValue {
                for (mpKey, mpSubVal) in mpDict {
                    if let key = mpKey.stringValue, let val = mpValueToAny(mpSubVal) {
                        dict[key] = val
                    } else {
                        print("Failed to convert '\(mpKey)' and '\(mpSubVal)'")
                    }
                }
            }
            return dict
        default:
            print("Failed to covnert unknown mpValue type: \(mpValue)")
            return nil
        }
    }
    
    //MARK: Serializers
    
    open func pack(_ data: [MessagePackValue]) -> Data? { // untested
        var packed = Data()
        
        for mpValue in data {
            packed.append(MessagePack.pack(mpValue))
        }
        return packed
    }
    
    open func pack(_ data: [Any]) -> Data? {
        var packed = Data()
        
        if let mpValue = anyToMPValue(anyVal: data) {
            packed.append(MessagePack.pack(mpValue))
        }
        
        return packed
    }
    
    open func unpack(_ data: Data) -> [Any]? {
        do {
            var unpacked = [Any]()
            let mpArray = try unpackAll(data)

            for mpValue in mpArray {
                if let value = mpValueToAny(mpValue) {
                    unpacked.append(value)
                }
            }
            
            return unpacked[0] as? [Any]
        }
        catch {
            return nil
        }
    }
}
#endif // MESSAGEPACK_SUPPORT

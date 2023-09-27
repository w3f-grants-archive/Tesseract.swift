//
//  SwiftPtr.swift
//  
//
//  Created by Yehor Popovych on 20.11.2022.
//

import Foundation
import CTesseract

public protocol CSwiftDropPtr: CType {
    associatedtype SObject: AnyObject
    
    var ptr: CAnyDropPtr { get set }
    
    init(value object: SObject)
    
    func unowned() -> CResult<SObject>
    mutating func owned() -> CResult<SObject>
    
    mutating func free() -> CResult<Void>
}

extension CSwiftDropPtr {
    public init(value object: SObject) {
        self = Self()
        self.ptr = .wrapped(object)
    }
    
    public func unowned() -> CResult<SObject> {
        self.ptr.unowned(SObject.self)
    }
    
    public mutating func owned() -> CResult<SObject> {
        self.ptr.owned(SObject.self)
    }
    
    public mutating func free() -> CResult<Void> {
        self.ptr.free()
    }
}

public protocol CSwiftAnyDropPtr: CType {
    var ptr: CAnyDropPtr { get set }
    
    init(value object: AnyObject)
    
    func unowned() -> CResult<AnyObject>
    func unowned<T>(_ type: T.Type) -> CResult<T>
    
    mutating func owned() -> CResult<AnyObject>
    mutating func owned<T>(_ type: T.Type) -> CResult<T>
    
    mutating func free() -> CResult<Void>
}

extension CSwiftAnyDropPtr {
    public init(value object: AnyObject) {
        self = Self()
        self.ptr = .wrapped(object)
    }
    
    public func unowned() -> CResult<AnyObject> {
        guard let obj = self.ptr.unowned() else {
            return .failure(.nullPtr)
        }
        return .success(obj)
    }
    
    public func unowned<T>(_ type: T.Type) -> CResult<T> {
        self.ptr.unowned(type)
    }
    
    public mutating func owned() -> CResult<AnyObject> {
        self.ptr.owned()
    }
    
    public mutating func owned<T>(_ type: T.Type) -> CResult<T> {
        self.ptr.owned(type)
    }
    
    public mutating func free() -> CResult<Void> {
        self.ptr.free()
    }
}

extension UnsafePointer where Pointee: CSwiftDropPtr {
    public func unowned() throws -> CResult<Pointee.SObject> {
        self.pointee.unowned()
    }
}

extension UnsafeMutablePointer where Pointee: CSwiftDropPtr {
    public func unowned() -> CResult<Pointee.SObject> {
        self.pointee.unowned()
    }
    
    public func owned() throws -> CResult<Pointee.SObject>  {
        self.pointee.owned()
    }
}

extension UnsafePointer where Pointee: CSwiftAnyDropPtr {
    public func unowned() -> CResult<AnyObject> {
        self.pointee.unowned()
    }
    
    public func unowned<T>(_ type: T.Type) -> CResult<T> {
        self.pointee.unowned(type)
    }
}

extension UnsafeMutablePointer where Pointee: CSwiftAnyDropPtr {
    public func unowned() throws -> CResult<AnyObject>  {
        self.pointee.unowned()
    }
    
    public func unowned<T>(_ type: T.Type) -> CResult<T> {
        self.pointee.unowned(type)
    }
    
    public func owned() throws -> CResult<AnyObject>  {
        self.pointee.owned()
    }
    
    public func owned<T>(_ type: T.Type) -> CResult<T> {
        self.pointee.owned(type)
    }
}

public extension SyncPtr_Void {
    func unowned() -> AnyObject {
        Unmanaged<AnyObject>.fromOpaque(self).takeUnretainedValue()
    }
    
    static func unowned(_ value: AnyObject) -> Self {
        UnsafeRawPointer(Unmanaged.passUnretained(value).toOpaque())
    }
    
    static func owned(_ value: AnyObject) -> Self {
        UnsafeRawPointer(Unmanaged.passRetained(value).toOpaque())
    }
}

public extension Optional where Wrapped == SyncPtr_Void {
    func unowned() -> AnyObject? {
        self?.unowned()
    }
    
    mutating func owned() -> AnyObject? {
        guard let ptr = self else { return nil }
        self = nil
        return Unmanaged<AnyObject>.fromOpaque(ptr).takeRetainedValue()
    }
    
    static func owned(_ value: AnyObject?) -> Self {
        value.map { UnsafeRawPointer(Unmanaged.passRetained($0).toOpaque()) }
    }
    
    static func unowned(_ value: AnyObject?) -> Self {
        value.map { UnsafeRawPointer(Unmanaged.passUnretained($0).toOpaque()) }
    }
}

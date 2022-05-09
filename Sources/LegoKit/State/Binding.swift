//
//  Binding.swift
//  LegoKit
//
//  Created by octree on 2022/5/5.
//
//  Copyright (c) 2022 Octree <octree@octree.me>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

/// 这个 PropertyWrapper 可以在任何情况下使用
/// 当是一个 ``LegoContainer`` 的属性时，会自动更新 ``LegoRenderer``
@propertyWrapper
public struct Binding<Value> {
    public var wrappedValue: Value {
        get { get() }
        set { set(newValue) }
    }

    private var get: () -> Value
    private var set: (Value) -> Void

    public var projectedValue: Binding<Value> {
        self
    }

    /// Create a property wrapper with initial value.
    /// - Parameter wrappedValue: The initial value.
    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.get = get
        self.set = set
    }

    public static subscript<T>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Binding>
    ) -> Value {
        get {
            return instance[keyPath: storageKeyPath].get()
        }
        set {
            instance[keyPath: storageKeyPath].set(newValue)
            if let container = instance as? LegoContainer {
                container.legoRenderer.apply(lego: container.lego)
            }
        }
    }
}

//
//  StateObject.swift
//  LegoKit
//
//  Created by octree on 2022/3/11.
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

import Combine
import Foundation

/// This property wrapper will apply ``Lego`` to ``LegoRenderer`` automatically while the ``Published`` value wa changed.
/// The instance that hold this property must confirm to ``LegoContainer`` protocol.
/// And the value must confirm to ``LegoObservableObject`` protocol
@propertyWrapper
public struct StateObject<Value: LegoObservableObject> {
    @available(*, unavailable,
               message: "This property wrapper can only be applied to ``LegoContainer``")
    public var wrappedValue: Value {
        get { fatalError() }
        // swiftlint:disable unused_setter_value
        set { fatalError() }
        // swiftlint:enable unused_setter_value
    }

    private class Box {
        weak var container: LegoContainer?
        var cancellable: AnyCancellable?
    }

    private var storage: Value
    private var box: Box = .init()

    /// Create a property wrapper with initial value
    /// - Parameter wrappedValue: The object to observed.
    public init(wrappedValue: Value) {
        storage = wrappedValue
    }

    private func bind(to instance: LegoContainer) {
        guard box.container !== instance else { return }
        box.container = instance
        box.cancellable = storage.objectDidChange.sink {
            guard let container = box.container else {
                return
            }
            container.legoRenderer.apply(lego: container.lego)
        }
    }

    public static subscript<T: LegoContainer>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, StateObject>
    ) -> Value {
        get {
            instance[keyPath: storageKeyPath].bind(to: instance)
            return instance[keyPath: storageKeyPath].storage
        }
        set {
            instance[keyPath: storageKeyPath].storage = newValue
        }
    }
}

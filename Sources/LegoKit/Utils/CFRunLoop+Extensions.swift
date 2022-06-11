//
//  Binding.swift
//  LegoKit
//
//  Created by octree on 2022/6/6.
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
import CoreFoundation
import Foundation

private final class _AnyObserverBox {
    private var _trigger: () -> Void
    init<T: AnyObject>(_ box: _ObserverBox<T>) {
        _trigger = { box.trigger() }
    }

    func trigger() {
        _trigger()
    }
}

private final class _ObserverBox<T: AnyObject> {
    weak var target: T?
    var action: (T) -> Void

    init(target: T, action: @escaping (T) -> Void) {
        self.target = target
        self.action = action
    }

    func trigger() {
        guard let target = target else {
            return
        }
        action(target)
    }

    func typeErased() -> _AnyObserverBox { .init(self) }
}

public extension CFRunLoop {
    func addObserver<T: AnyObject>(_ target: T,
                                   activity: CFRunLoopActivity,
                                   mode: CFRunLoopMode = .defaultMode,
                                   repeat: Bool = true,
                                   order: CFIndex = 0,
                                   action: @escaping (T) -> Void) -> AnyCancellable
    {
        let box = _ObserverBox(target: target, action: action).typeErased()
        let info = Unmanaged.passRetained(box).toOpaque()
        var context = CFRunLoopObserverContext(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)
        let observer = CFRunLoopObserverCreate(kCFAllocatorDefault, activity.rawValue, `repeat`, order, runLoopObserverCallback(), &context)
        CFRunLoopAddObserver(self,
                             observer,
                             mode)
        return .init {
            CFRunLoopRemoveObserver(self, observer, mode)
        }
    }

    func runLoopObserverCallback() -> CFRunLoopObserverCallBack {
        return { _, _, info in
            guard let info = info else {
                return
            }
            let box = Unmanaged<_AnyObserverBox>.fromOpaque(info).takeUnretainedValue()
            box.trigger()
        }
    }
}

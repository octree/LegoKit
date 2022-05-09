//
//  ObservableObject.swift
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

import UIKit

final class Cancellation {
    var cancel: () -> ()

    init(_ action: @escaping () -> ()) {
        self.cancel = action
    }

    deinit {
        cancel()
    }
}

public final class ObjectDidChangePublisher {
    private var currentID: Int = 0
    private(set) var actions: [Int: () -> ()] = [:]

    public func send() {
        actions.forEach { $0.value() }
    }

    func observe(_ action: @escaping () -> ()) -> Cancellation {
        let id = currentID
        currentID += 1
        actions[id] = action
        return Cancellation { [weak self] in
            self?.actions[id] = nil
        }
    }
}

public protocol LegoObservableObject: AnyObject {
    var objectDidChange: ObjectDidChangePublisher { get }
}

private enum AssociatedKeys {
    static var publisher = "LegoKit.ObjectDidChangePublisher"
}

public extension LegoObservableObject {
    var objectDidChange: ObjectDidChangePublisher {
        var publisher = objc_getAssociatedObject(self, &AssociatedKeys.publisher) as? ObjectDidChangePublisher
        if publisher == nil {
            publisher = .init()
            objc_setAssociatedObject(self, &AssociatedKeys.publisher, publisher, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return publisher!
    }
}

//
//  Lego.swift
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

@MainActor
public struct Lego {
    public var sections: [AnySection]

    public init(@SectionBuilder sections: () -> [AnySection]) {
        self.sections = sections()
    }
}

public extension Lego {
    subscript(indexPath: IndexPath) -> AnyItem {
        sections[indexPath.section].items[indexPath.item]
    }

    subscript<C: TypedItemType>(indexPath: IndexPath, as type: C.Type) -> C? {
        self[indexPath].as(type)
    }
}

extension Lego {
    func indexPathForItem<ID: Hashable & Sendable>(with identifier: ID) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() where item.anyID == AnyID(identifier) {
                return IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
        return nil
    }

    func indexPathForItem(with identifier: AnyID) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() where item.anyID == identifier {
                return IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
        return nil
    }
}

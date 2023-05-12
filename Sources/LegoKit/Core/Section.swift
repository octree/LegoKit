//
//  Section.swift
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

public struct Section<ID: Hashable> {
    public var id: ID
    var layout: (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    public var items: [AnyItem] = []

    public init(id: ID, layout: NSCollectionLayoutSection, @ItemBuilder items: () -> [AnyItem]) {
        self.id = id
        self.layout = { _ in layout }
        self.items = items()
    }

    public init(id: ID, layout: @escaping () -> NSCollectionLayoutSection, @ItemBuilder items: () -> [AnyItem]) {
        self.id = id
        self.layout = { _ in layout() }
        self.items = items()
    }

    public init(id: ID, layout: @escaping (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection, @ItemBuilder items: () -> [AnyItem]) {
        self.id = id
        self.layout = layout
        self.items = items()
    }
}

public struct AnySection {
    public var id: AnyHashable
    var layout: (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    public var items: [AnyItem] = []

    init<ID>(_ section: Section<ID>) {
        id = section.id
        layout = section.layout
        items = section.items
    }
}

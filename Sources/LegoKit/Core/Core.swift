//
//  Core.swift
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

/// A type represents the part of a lego cell
public protocol CellType {}

/// A Lego cell with a specified Item type
public protocol TypedCellType: CellType {
    associatedtype Item
    func update(with item: Item)
    static func layout(constraintsTo size: CGSize, with item: Item) -> CGSize
}

public protocol ItemType {
    var anyID: AnyHashable { get }
    func createCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell
}

public struct AnyItem: ItemType {
    public var base: ItemType
    public var anyID: AnyHashable { base.anyID }
    private var _layout: (CGSize) -> CGSize
    public func createCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        base.createCell(in: collectionView, at: indexPath)
    }

    init<C: TypedItemType>(_ item: C) {
        base = item
        _layout = { item.layout(constraintsTo: $0) }
    }

    func `as`<C: TypedItemType>(_ type: C.Type) -> C? {
        base as? C
    }

    func layout(constraintsTo size: CGSize) -> CGSize {
        _layout(size)
    }
}

public protocol TypedItemType: ItemType {
    associatedtype ID: Hashable
    associatedtype CellType: UICollectionViewCell & TypedCellType where CellType.Item == Self
    var id: ID { get }
}

public extension TypedItemType {
    var asItems: [AnyItem] { [AnyItem(self)] }
}

extension TypedItemType {
    func layout(constraintsTo size: CGSize) -> CGSize {
        CellType.layout(constraintsTo: size, with: self)
    }
}

public extension TypedItemType {
    var anyID: AnyHashable { id }
}

public extension ItemType {
    func createCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        fatalError()
    }
}

extension TypedItemType {
    static var identifier: String {
        return String(describing: CellType.self)
    }

    public func createCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        Self.register(in: collectionView)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.identifier, for: indexPath) as? CellType else {
            fatalError("Cannot create a new cell with identifier: \(Self.identifier), Expected cell type: \(CellType.self)")
        }
        cell.update(with: self)
        return cell
    }

    static func register(in collectionView: UICollectionView) {
        collectionView.register(CellType.classForCoder(), forCellWithReuseIdentifier: identifier)
    }
}

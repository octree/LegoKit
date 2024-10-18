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

public struct AnyID: Hashable, Sendable, Equatable {
    private nonisolated(unsafe) var value: Any
    private nonisolated(unsafe) var hashInto: (inout Hasher) -> Void
    private nonisolated(unsafe) var equalTo: (AnyID) -> Bool
    init<Value: Hashable & Sendable>(_ value: Value) {
        self.value = value
        hashInto = {
            $0.combine(value)
        }
        equalTo = {
            guard let other = $0.value as? Value else { return false }
            return other == value
        }
    }

    public func hash(into hasher: inout Hasher) {
        hashInto(&hasher)
    }

    public static func == (lhs: AnyID, rhs: AnyID) -> Bool {
        lhs.equalTo(rhs)
    }
}

/// A type represents the part of a lego cell
@MainActor
public protocol CellType {}

/// A Lego cell with a specified Item type
@MainActor
public protocol TypedCellType: CellType {
    associatedtype Item
    func update(with item: Item)
}

@MainActor
public protocol ItemType {
    var anyID: AnyID { get }
    func createCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell
}

@MainActor
public struct AnyItem: ItemType {
    public var base: ItemType
    public var anyID: AnyID { base.anyID }
    private var _updateCell: (UICollectionViewCell) -> Void
    public func createCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        base.createCell(in: collectionView, at: indexPath)
    }

    init<C: TypedItemType>(_ item: C) {
        base = item
        _updateCell = { item.updateCell($0) }
    }

    func updateCell(_ cell: UICollectionViewCell) {
        _updateCell(cell)
    }

    func `as`<C: TypedItemType>(_ type: C.Type) -> C? {
        base as? C
    }
}

@MainActor
public protocol TypedItemType: ItemType {
    associatedtype ID: Hashable & Sendable
    associatedtype CellType: UICollectionViewCell, TypedCellType where CellType.Item == Self
    var id: ID { get }
}

public extension TypedItemType {
    var asItems: [AnyItem] { [AnyItem(self)] }
}

public extension TypedItemType {
    var anyID: AnyID { .init(id) }
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

extension ItemType {
    func updateCell(_ cell: UICollectionViewCell) { fatalError() }
}

extension TypedItemType {
    func updateCell(_ cell: UICollectionViewCell) {
        guard let cell = cell as? CellType else { return }
        cell.update(with: self)
    }
}

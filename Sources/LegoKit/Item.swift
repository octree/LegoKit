//
//  Item.swift
//  
//
//  Created by Octree on 2019/6/13.
//

import UIKit

public protocol ItemsBuilderComponents {
    var asItems: [Item] { get }
}

@_functionBuilder public struct ItemsBuilder {
    public static func buildBlock(_ items: ItemsBuilderComponents...) -> ItemsBuilderComponents {
        return items.flatMap { $0.asItems }
    }
    
    public static func buildIf(_ items: ItemsBuilderComponents?...) -> ItemsBuilderComponents {
        return items.flatMap { $0?.asItems ?? [] }
    }
}

public protocol ItemType: ItemsBuilderComponents {
    var isHidden: Bool { get set }
    func createCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> BaseCell
    func sizeThatFits(to size: CGSize) -> CGSize
}

public protocol TypedItemType: ItemType {
    associatedtype Value
    associatedtype CellType: TypedCellType where CellType.Value == Value
    var value: Value { get set }
}

open class Item: ItemType {
    open var asItems: [Item] {
        return [self]
    }
    open var isHidden: Bool = false
    open func createCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> BaseCell {
        return BaseCell()
    }
    open func sizeThatFits(to size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 44)
    }
}

open class TypedItem<V, C: BaseTypedCell<V>>: Item, TypedItemType {
    public typealias CellType = C
    public typealias Value = V
    open var value: V
    
    public init(value: V) {
        self.value = value
        super.init()
    }
    
    static func register(in collectionView: UICollectionView) {
        collectionView.register(CellType.classForCoder(), forCellWithReuseIdentifier: identifier)
    }
    
    override open func createCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> BaseCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.identifier, for: indexPath) as? CellType else {
            fatalError("Cannot create a new cell with identifier: \(Self.identifier), Expected cell type: \(CellType.self)")
        }
        cell.renderer(with: value)
        return cell
    }
}

extension TypedItem {
    static var identifier: String {
        return String(describing: CellType.self)
    }
}

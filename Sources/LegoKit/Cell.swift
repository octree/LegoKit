//
//  Cell.swift
//  
//
//  Created by Octree on 2019/6/13.
//

import UIKit


public protocol CellType {
}

public protocol TypedCellType: CellType {
    associatedtype Value
    
    func renderer(with value: Value)
}

open class BaseCell: UICollectionViewCell, CellType {
}

open class BaseTypedCell<V>: BaseCell, TypedCellType {
    public typealias Value = V
    
    open func renderer(with value: V) {
    }
}

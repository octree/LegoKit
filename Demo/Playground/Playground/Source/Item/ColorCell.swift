//
//  ImageCell.swift
//  LegoKit
//
//  Created by octree on 2022/3/10.
//
//  Copyright (c) 2022 Octree <octree.liu@ponyft.com>

import LegoKit
import UIKit

public struct ColorItem: TypedItemType {
    public typealias CellType = ColorCell
    public var id: UUID
    public var color: UIColor
    public var height: CGFloat
}

public class ColorCell: UICollectionViewCell, TypedCellType {
    public typealias Item = ColorItem

    public func update(with item: ColorItem) {
        backgroundColor = item.color
    }

    public static func layout(constraintsTo size: CGSize, with item: ColorItem) -> CGSize {
        CGSize(width: size.width, height: item.height)
    }
}

extension UIColor {
    static var random: UIColor {
        UIColor(red: CGFloat.random(in: 0...1),
                green: .random(in: 0...1),
                blue: .random(in: 0...1),
                alpha: 1)
    }
}


extension ColorItem {
    static var random: ColorItem {
        ColorItem(id: .init(), color: .random, height: .random(in: 40...120))
    }
}

//
//  GroupCell.swift
//  LegoKit
//
//  Created by octree on 2022/3/11.
//
//  Copyright (c) 2022 Octree <octree.liu@ponyft.com>

import LegoKit
import UIKit

// MARK: - Item


/// Item 用来描述渲染一种 Cell 需要携带的数据。
/// 并从类型和 ``GroupCell`` 进行绑定
public struct GroupItem: TypedItemType {
    // 绑定 Cell 的类型
    public typealias CellType = GroupCell
    // 预留 ID，为以后做准备
    public var id: UUID
    // 分组名称
    public var name: String
}

// MARK: - Cell

public class GroupCell: UICollectionViewCell, TypedCellType {
    public typealias Item = GroupItem

    // MARK: - Properties

    private lazy var nameLabel: UILabel = .init()

    // MARK: - Life Cyle

    // MARK: Initializer

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - TypedCellType

    public func update(with item: Item) {
        nameLabel.text = item.name
    }

    public static func layout(constraintsTo size: CGSize, with item: Item) -> CGSize {
        CGSize(width: size.width, height: 40)
    }

    // MARK: - Private

    // MARK: Setup

    private func setup() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        contentView.addConstraints([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}

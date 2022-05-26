//
//  UserCell.swift
//  LegoKit
//
//  Created by octree on 2022/3/11.
//
//  Copyright (c) 2022 Octree <octree.liu@ponyft.com>

import LegoKit
import UIKit

// MARK: - Item

/// Item 用来描述渲染一种 Cell 需要携带的数据。
/// 并从类型和 ``UserCell`` 进行绑定
public struct UserItem: TypedItemType {
    // 绑定 Cell 的类型
    public typealias CellType = UserCell
    // 预留 ID，为以后做准备
    public var id: UUID
    // 用户名称
    public var name: String
    public var gender: Gender
}

// MARK: - Cell

public class UserCell: UICollectionViewCell, TypedCellType {
    public typealias Item = UserItem

    // MARK: - Properties

    private lazy var nameLabel: UILabel = .init()
    private lazy var genderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()

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
        genderLabel.text = "性别：\(item.gender)"
    }

    public static func layout(constraintsTo size: CGSize, with item: Item) -> CGSize {
        CGSize(width: size.width, height: 60)
    }

    // MARK: - Private

    // MARK: Setup

    private func setup() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        contentView.addConstraints([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        ])

        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(genderLabel)
        contentView.addConstraints([
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            genderLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}

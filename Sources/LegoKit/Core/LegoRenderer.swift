//
//  LegoRenderer.swift
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

public final class LegoRenderer: NSObject {
    public private(set) lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var layout = CompositionLayout(delegate: self)
    private lazy var dataSource: LegoDataSource = {
        let dataSource: LegoDataSource
        dataSource = LegoDiffableDataSource(collectionView: collectionView) { [weak self] in
            self?.cellProvider(collectionView: $0, indexPath: $1, itemID: $2)
        }
        return dataSource
    }()

    public private(set) var lego: Lego

    public init(lego: Lego) {
        self.lego = lego
        super.init()
    }

    public func render(in view: UIView, config: (UICollectionView) -> Void = { _ in }) {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        dataSource.apply(lego: lego, animatingDifferences: true)
        config(collectionView)
    }

    /// Update collectionView with a specified ``Lego``
    /// - Parameters:
    ///   - lego: The lego specified to apply
    ///   - animatingDifferences: A bool value indicates whether perform animations.
    public func apply(lego: Lego, animatingDifferences: Bool = true) {
        self.lego = lego
        dataSource.apply(lego: lego, animatingDifferences: animatingDifferences)
    }

    private func cellProvider(collectionView: UICollectionView, indexPath: IndexPath, itemID: AnyHashable) -> UICollectionViewCell? {
        lego[indexPath].createCell(in: collectionView, at: indexPath)
    }
}

// MARK: - CompositionLayoutDelegate

extension LegoRenderer: CompositionLayoutDelegate {
    public func collectionView(_ collectionView: UICollectionView, sectionLayoutAt section: Int) -> SectionLayout {
        lego.sections[section].layout
    }

    public func collectionView(_ collectionView: UICollectionView, sizeThatFits size: CGSize, at indexPath: IndexPath) -> CGSize {
        return lego[indexPath].layout(constraintsTo: size)
    }
}

// MARK: - Subscript

public extension LegoRenderer {
    subscript(indexPath: IndexPath) -> AnyItem {
        lego[indexPath]
    }

    subscript<C: TypedItemType>(indexPath: IndexPath, as type: C.Type) -> C? {
        lego[indexPath, as: type]
    }
}

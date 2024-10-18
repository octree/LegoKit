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

import Combine
import UIKit

public typealias CellProvider = (UICollectionView, IndexPath, AnyHashable) -> UICollectionViewCell?
public typealias SupplementaryViewProvider = (UICollectionView, String, IndexPath) -> UICollectionReusableView?

@MainActor
public final class LegoRenderer {
    public private(set) lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var layout: UICollectionViewCompositionalLayout = {
        let provider: UICollectionViewCompositionalLayoutSectionProvider = { [unowned self] section, environment in
            lego.sections[section].layout(environment)
        }
        if let layoutConfiguration {
            return .init(sectionProvider: provider, configuration: layoutConfiguration)
        } else {
            return .init(sectionProvider: provider)
        }
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<AnyID, AnyID> = .init(collectionView: collectionView) { [weak self] in
        self?.cellProvider(collectionView: $0, indexPath: $1, itemID: $2)
    }

    public var supplementaryViewProvider: SupplementaryViewProvider? {
        get {
            dataSource.supplementaryViewProvider
        }
        set {
            dataSource.supplementaryViewProvider = newValue
        }
    }

    private var layoutConfiguration: UICollectionViewCompositionalLayoutConfiguration?
    public var isAnimationEnabled: Bool = true

    public private(set) var lego: Lego
    public init(lego: Lego, layoutConfiguration: UICollectionViewCompositionalLayoutConfiguration? = nil) {
        self.layoutConfiguration = layoutConfiguration
        self.lego = lego
    }

    public func render(in view: UIView, config: (UICollectionView) -> Void = { _ in }) {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        config(collectionView)
        apply(lego: lego, animatingDifferences: true)
    }

    /// Update collectionView with a specified ``Lego``
    /// - Parameters:
    ///   - lego: The lego specified to apply
    ///   - animatingDifferences: A bool value indicates whether perform animations.
    public func apply(lego: Lego, animatingDifferences: Bool? = nil) {
        var snapshot = NSDiffableDataSourceSnapshot<AnyID, AnyID>()
        snapshot.appendSections(lego.sections.map { $0.id })
        lego.sections.forEach {
            snapshot.appendItems($0.items.map { $0.anyID }, toSection: $0.id)
        }
        let allIdentifiers = Set(snapshot.itemIdentifiers)
        for indexPath in collectionView.indexPathsForVisibleItems {
            guard let identifier = dataSource.itemIdentifier(for: indexPath),
                  allIdentifiers.contains(identifier),
                  let cell = collectionView.cellForItem(at: indexPath),
                  let newIndexPath = lego.indexPathForItem(with: identifier)
            else {
                continue
            }

            lego[newIndexPath].updateCell(cell)
        }
        self.lego = lego
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences ?? isAnimationEnabled)
    }

    private func cellProvider(collectionView: UICollectionView, indexPath: IndexPath, itemID: AnyHashable) -> UICollectionViewCell? {
        lego[indexPath].createCell(in: collectionView, at: indexPath)
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

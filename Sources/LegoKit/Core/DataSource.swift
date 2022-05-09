//
//  Datasource.swift
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

public typealias CellProvider = (UICollectionView, IndexPath, AnyHashable) -> UICollectionViewCell?

public protocol LegoDataSource {
    init(collectionView: UICollectionView, cellProvider: @escaping CellProvider)
    func apply(lego: Lego, animatingDifferences: Bool)
}

@available(iOS 13.0, *)
public final class LegoDiffableDataSource: LegoDataSource {
    private var dataSource: UICollectionViewDiffableDataSource<AnyHashable, AnyHashable>
    public required init(collectionView: UICollectionView, cellProvider: @escaping CellProvider) {
        dataSource = .init(collectionView: collectionView, cellProvider: cellProvider)
    }

    public func apply(lego: Lego, animatingDifferences: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<AnyHashable, AnyHashable>()
        snapshot.appendSections(lego.sections.map { $0.id })
        lego.sections.forEach {
            snapshot.appendItems($0.items.map { $0.anyID }, toSection: $0.id)
        }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

public final class LegoLegacyDataSource: NSObject, LegoDataSource {
    private var lego: Lego = Lego {}
    private weak var collectionView: UICollectionView?
    public required init(collectionView: UICollectionView, cellProvider: @escaping CellProvider) {
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
    }

    public func apply(lego: Lego, animatingDifferences: Bool) {
        self.lego = lego
        collectionView?.reloadData()
    }
}

extension LegoLegacyDataSource: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lego.sections[section].items.count
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return lego.sections.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return lego[indexPath].createCell(in: collectionView, at: indexPath)
    }
}

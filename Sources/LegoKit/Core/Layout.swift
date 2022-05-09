//
//  Layout.swift
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

public protocol CompositionLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, sectionLayoutAt section: Int) -> SectionLayout
    func collectionView(_ collectionView: UICollectionView, sizeThatFits size: CGSize, at indexPath: IndexPath) -> CGSize
}

/// A model provides context info for a  ``SectionLayout``
public final class LayoutContext {
    public private(set) weak var collectionView: UICollectionView?
    public internal(set) var consumedHeight: CGFloat = 0
    public private(set) var contentWidth: CGFloat = 0
    public weak var delegate: CompositionLayoutDelegate?

    init(collectionView: UICollectionView?, delegate: CompositionLayoutDelegate?) {
        self.collectionView = collectionView
        self.delegate = delegate
        clean()
    }

    func clean() {
        consumedHeight = 0
        guard let collectionView = collectionView else {
            contentWidth = 0
            return
        }
        contentWidth = collectionView.frame.inset(by: collectionView.contentInset).width
    }
}

public protocol SectionLayout: AnyObject {
    var layoutAttributes: [UICollectionViewLayoutAttributes] { get }
    var section: Int { get set }
    var frame: CGRect { get set }
    var contentSize: CGSize { get }
    func prepare(in context: LayoutContext)
}

extension SectionLayout {
    func layoutAttributesForItem(at index: Int) -> UICollectionViewLayoutAttributes {
        return layoutAttributes[index]
    }

    subscript(index: Int) -> UICollectionViewLayoutAttributes {
        return layoutAttributes[index]
    }

    func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        return layoutAttributes.filter {
            $0.frame.intersects(rect)
        }
    }
}

final class CompositionLayout: UICollectionViewLayout {
    weak var delegate: CompositionLayoutDelegate?
    private var sectionLayouts: [SectionLayout] = []
    private lazy var context: LayoutContext = .init(collectionView: self.collectionView, delegate: delegate)

    override var collectionViewContentSize: CGSize {
        return CGSize(width: context.contentWidth, height: context.consumedHeight)
    }

    init(delegate: CompositionLayoutDelegate?) {
        self.delegate = delegate
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        context.clean()
        guard let collectionView = collectionView,
              let delegate = delegate else { return }

        sectionLayouts = (0 ..< collectionView.numberOfSections).map { index in
            let layout = delegate.collectionView(collectionView, sectionLayoutAt: index)
            layout.section = index
            layout.prepare(in: context)
            layout.frame = CGRect(x: collectionView.contentInset.left,
                                  y: context.consumedHeight,
                                  width: context.contentWidth,
                                  height: layout.contentSize.height)
            context.consumedHeight += layout.contentSize.height
            return layout
        }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return sectionLayouts[indexPath.section][indexPath.item]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return sectionLayouts.flatMap { $0.layoutAttributesForElements(in: rect) }
    }
}

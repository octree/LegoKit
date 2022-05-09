//
//  WaterfalSectionLayout.swift
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

open class WaterfallLayout: SectionLayout {
    open var layoutAttributes = [UICollectionViewLayoutAttributes]()
    open var section: Int = 0
    open var frame = CGRect()
    open private(set) var contentSize = CGSize()

    open var contentInsets: UIEdgeInsets
    open var horizontalSpacing: CGFloat
    open var verticalSpacing: CGFloat
    open var numberOfColumns: Int

    public init(numberOfColumns: Int = 1, horizontalSpacing: CGFloat = 1, verticalSpacing: CGFloat = 1, contentInsets: UIEdgeInsets = UIEdgeInsets()) {
        self.numberOfColumns = numberOfColumns
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.contentInsets = contentInsets
    }

    open func prepare(in context: LayoutContext) {
        guard let collectionView = context.collectionView,
              let delegate = context.delegate
        else {
            return
        }

        layoutAttributes = []
        var heightCache = setupHeightCache(in: context)
        let contentWidth = context.contentWidth
        let itemsWidth = contentWidth - contentInsets.left - contentInsets.right - horizontalSpacing * CGFloat(numberOfColumns - 1)
        let itemWidth = itemsWidth / CGFloat(numberOfColumns)
        let itemCount = collectionView.numberOfItems(inSection: section)
        let offsetX = contentInsets.left

        for index in 0..<itemCount {
            let col = index % numberOfColumns
            let x = offsetX + (itemWidth + horizontalSpacing) * CGFloat(col)
            let indexPath = IndexPath(item: index, section: section)
            let size = delegate.collectionView(collectionView, sizeThatFits: CGSize(width: itemWidth, height: CGFloat.greatestFiniteMagnitude), at: indexPath)
            let y = heightCache[col]
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
            layoutAttributes.append(attributes)
            heightCache[col] = y + verticalSpacing + size.height
        }

        let maxY = heightCache.reduce(CGFloat.leastNormalMagnitude, max) - (itemCount > 0 ? verticalSpacing : 0) + contentInsets.bottom
        let height = maxY - context.consumedHeight
        contentSize = CGSize(width: contentWidth, height: height)
    }

    private func setupHeightCache(in context: LayoutContext) -> [CGFloat] {
        return (0..<numberOfColumns).map { _ in
            context.consumedHeight + self.contentInsets.top
        }
    }
}

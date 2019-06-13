//
//  Layout.swift
//  
//
//  Created by Octree on 2019/6/13.
//

import UIKit

public protocol CompositionLayoutDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeThatFits size:CGSize, at indexPath: IndexPath) -> CGSize
}

public final class LayoutContext {
    public private(set) weak var collectionView: UICollectionView?
    public internal(set) var consumedHeight: CGFloat = 0
    public private(set) var contentWidth: CGFloat = 0
    public var delegate: CompositionLayoutDelegate? {
        collectionView?.delegate as? CompositionLayoutDelegate
    }
    init(collectionView: UICollectionView?) {
        self.collectionView = collectionView
        clean()
    }
    func clean() {
        consumedHeight = 0
        guard let collectionView = self.collectionView else {
            contentWidth = 0
            return
        }
        contentWidth = collectionView.frame.inset(by: collectionView.contentInset).width
    }
}

public protocol SectionLayout: class {
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
    
    var sectionLayouts: [SectionLayout]
    private lazy var context: LayoutContext = {
        return LayoutContext(collectionView: self.collectionView)
    }()
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: context.contentWidth, height: context.consumedHeight)
    }
    
    init(sectionLayouts: [SectionLayout] = []) {
        self.sectionLayouts = sectionLayouts
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        context.clean()
        for (idx, layout) in sectionLayouts.enumerated() {
            layout.section = idx
            layout.prepare(in: context)
            layout.frame = CGRect(x: self.collectionView?.contentInset.left ?? 0,
                                  y: context.consumedHeight,
                                  width: context.contentWidth,
                                  height: layout.contentSize.height)
            context.consumedHeight += layout.contentSize.height
        }
        
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return sectionLayouts[indexPath.section][indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return sectionLayouts.flatMap { $0.layoutAttributesForElements(in: rect) }
    }
}

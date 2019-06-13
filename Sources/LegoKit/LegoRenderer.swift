//
//  LegoRenderer.swift
//  
//
//  Created by Octree on 2019/6/13.
//

import UIKit

extension Lego {
    subscript(indexPath: IndexPath) -> Item {
        return sections[indexPath.section].items[indexPath.item]
    }
}

func id<T>(_ t: T) -> T {
    return t
}

public final class LegoRenderer: NSObject {
    public private(set) lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let layout = CompositionLayout()
    public private(set) var lego: Lego
    public init(lego: Lego) {
        self.lego = lego
        super.init()
    }
    
    public func render(in view: UIView, config: (UICollectionView) -> Void = { _ in }) {
        view.addSubview(collectionView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
                ])
        } else {
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
        }
        layout.sectionLayouts = lego.sections.map { $0.layout }
        collectionView.delegate = self
        collectionView.dataSource = self
        config(collectionView)
    }
    
    public func use<T, V, C>(itemType: T.Type) where T: TypedItem<V, C> {
        T.register(in: self.collectionView)
    }
    
    public func reload() {
        collectionView.reloadData()
    }
}

extension LegoRenderer: CompositionLayoutDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, sizeThatFits size: CGSize, at indexPath: IndexPath) -> CGSize {
        return lego[indexPath].sizeThatFits(to: size)
    }
}

extension LegoRenderer: UICollectionViewDataSource {
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



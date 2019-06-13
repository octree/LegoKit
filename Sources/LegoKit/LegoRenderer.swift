//
//  LegoRenderer.swift
//  
//
//  Created by Octree on 2019/6/13.
//

import UIKit

public protocol SectionsMiddleware {
    func process(sections: [Section], onNext: ([Section]) -> [Section]) -> [Section]
}

public protocol ItemsMiddleware {
    func process(items: [Item], onNext: ([Item]) -> [Item]) -> [Item]
}

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
    private var itemProccessor: ([Item]) -> [Item] = id
    private var sectionProccessor: ([Section]) -> [Section] = id
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
    
    public func useItemsMiddleware(_ middleware: ItemsMiddleware) {
        let f = itemProccessor
        itemProccessor = {
            middleware.process(items: $0, onNext: f)
        }
    }
    
    public func useSectionsMiddleware(_ middleware: SectionsMiddleware) {
        let f = sectionProccessor
        sectionProccessor = {
            middleware.process(sections: $0, onNext: f)
        }
    }
}

extension LegoRenderer: CompositionLayoutDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, sizeThatFits size: CGSize, at indexPath: IndexPath) -> CGSize {
        return lego[indexPath].sizeThatFits(to: size)
    }
}

extension LegoRenderer: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numberOfItemsInSection", lego.sections[section].items.count)
        return lego.sections[section].items.count
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("numberOfSections", lego.sections.count)
        return lego.sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return lego[indexPath].createCell(in: collectionView, at: indexPath)
    }
}



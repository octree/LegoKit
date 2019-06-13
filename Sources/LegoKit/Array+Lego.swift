//
//  Array+Lego.swift
//  
//
//  Created by Octree on 2019/6/13.
//

import Foundation

extension Array: ItemsBuilderComponents where Element: Item {
    public var asItems: [Item] {
        return self
    }
}

extension Array: SectionsBuilderComponents where Element: Section {
    public var asSections: [Section] {
        return self
    }
}

//
//  Lego.swift
//  
//
//  Created by Octree on 2019/6/13.
//

import Foundation

public protocol LegoType {
    var sections: [Section] { get set }
}

public final class Lego: LegoType {
    public var sections: [Section]
    public init(@SectionsBuilder builder: () -> SectionsBuilderComponents  = { [] }) {
        sections = builder().asSections
    }
    init(sections: [Section]) {
        self.sections = sections
    }
}

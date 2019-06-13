//
//  Section.swift
//  
//
//  Created by Octree on 2019/6/13.
//

import Foundation

public protocol SectionsBuilderComponents {
    var asSections: [Section] { get }
}


@_functionBuilder public struct SectionsBuilder {
    
    public static func buildBlock(_ sections: SectionsBuilderComponents...) -> SectionsBuilderComponents {
        return sections.flatMap { $0.asSections }
    }
    
    public static func buildIf(_ sections: SectionsBuilderComponents?...) -> SectionsBuilderComponents {
        return sections.flatMap { $0?.asSections ?? [] }
    }
}

public protocol SectionType: SectionsBuilderComponents {
    var items: [Item] { get set }
    var layout:SectionLayout { get }
}

open class Section: SectionType {
    open var layout: SectionLayout
    open var asSections: [Section] {
        return [self]
    }
    open var items: [Item]
    public init(layout: SectionLayout  = WaterFlowLayout(), @ItemsBuilder builder: () -> ItemsBuilderComponents = { [] }) {
        self.layout = layout
        items = builder().asItems
    }
    
    public init(layout: SectionLayout, items: [Item]) {
        self.layout = layout
        self.items = items
    }
}

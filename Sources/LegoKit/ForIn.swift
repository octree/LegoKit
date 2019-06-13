//
//  ForIn.swift
//  
//
//  Created by Octree on 2019/6/13.
//

import Foundation

public struct ForIn<S: Sequence>: ItemsBuilderComponents, SectionsBuilderComponents {
    
    private let s: S
    private let itemBuilder: ((S.Element) -> ItemsBuilderComponents)?
    private let sectionBuilder: ((S.Element) -> SectionsBuilderComponents)?
    private let isSection: Bool
    public init(_ s: S, @ItemsBuilder itemBuilder: @escaping (S.Element) -> ItemsBuilderComponents = { _ in [] }) {
        self.s = s
        self.itemBuilder = itemBuilder
        self.isSection = false
        self.sectionBuilder = nil
    }
    
    public init(_ s: S, @ItemsBuilder sectionBuilder: @escaping (S.Element) -> SectionsBuilderComponents = { _ in [] }) {
        self.s = s
        self.sectionBuilder = sectionBuilder
        self.isSection = true
        self.itemBuilder = nil
    }
    
    public var asItems: [Item] {
        return s.flatMap { self.itemBuilder!($0).asItems }
    }
    
    public var asSections: [Section] {
        return s.flatMap { self.sectionBuilder!($0).asSections }
    }
}

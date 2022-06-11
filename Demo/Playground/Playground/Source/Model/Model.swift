//
//  Model.swift
//  LegoKit
//
//  Created by octree on 2022/3/11.
//
//  Copyright (c) 2022 Octree <octree.liu@ponyft.com>

import Foundation

public enum Gender: CaseIterable {
    case male
    case female
}

extension Gender: CustomStringConvertible {
    public var description: String {
        switch self {
        case .male:
            return "男"
        case .female:
            return "女"
        }
    }
}

extension Gender {
    static var random: Gender { allCases.randomElement()! }
}

public struct Group: Equatable {
    public var id: UUID = .init()
    public var name: String
    public var users: [User]
}

public struct User: Equatable {
    public var id: UUID = .init()
    public var name: String
    public var gender: Gender = .random
}

extension Group {
    static var initialGroups: [Group] {
        [
            .init(name: "iOS", users: [
                User(name: "Octree"),
                User(name: "Chris"),
                User(name: "James")
            ]),
            .init(name: "Android", users: [
                User(name: "A"),
                User(name: "B"),
                User(name: "C")
            ])
        ]
    }
}

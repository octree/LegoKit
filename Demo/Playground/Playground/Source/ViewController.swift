//
//  ViewController.swift
//  Playground
//
//  Created by Octree on 2022/3/10.
//

import LegoKit
import UIKit

class ViewModel: LegoObservableObject {
    @LegoPublished var groups: [Group] = Group.initialGroups

    func addMember() {
        let alpha = "abcdefghijklmnopqrstuvwxyz"
        let name = String((0 ... 8).map { _ in alpha.randomElement()! }).capitalized
        groups[0].users.append(.init(name: name))
    }
}

class ViewController: UIViewController, LegoContainer {
    @StateObject var viewModel = ViewModel()
    @State var flag: Bool = true

    private var sectionLayout: NSCollectionLayoutSection = {
        let size: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1
        return section
    }()

    var lego: Lego {
        Lego {
            for group in viewModel.groups {
                Section(id: group.id, layout: sectionLayout) {
                    if flag {
                        GroupItem(id: group.id, name: group.name)
                    }
                    for user in group.users {
                        UserItem(id: user.id, name: user.name, gender: user.gender)
                    }
                }
            }
        }
    }

    lazy var legoRenderer: LegoRenderer = .init(lego: lego)

    override func viewDidLoad() {
        super.viewDidLoad()
        legoRenderer.render(in: view) {
            $0.backgroundColor = UIColor(white: 0.95, alpha: 1)
            $0.alwaysBounceVertical = true
        }

        let barItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(toggle))
        let push = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(push))
        navigationItem.rightBarButtonItems = [push, barItem]

        let updateItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(updateItem))
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMember))
        navigationItem.leftBarButtonItems = [addItem, updateItem]
    }

    @objc private func updateItem() {
        viewModel.groups[0].users[0].name += " Octree"
    }

    @objc private func toggle() {
        flag.toggle()
    }

    @objc private func addMember() {
        viewModel.addMember()
    }

    @objc private func push() {
        let vc = ToggleViewController(flag: $flag)
        navigationController?.pushViewController(vc, animated: true)
    }
}

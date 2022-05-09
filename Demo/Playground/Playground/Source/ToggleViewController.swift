//
//  ToggleViewController.swift
//  LegoKit
//
//  Created by octree on 2022/5/5.
//
//  Copyright (c) 2022 Octree <octree.liu@ponyft.com>

import LegoKit
import UIKit

public final class ToggleViewController: UIViewController {
    @Binding var flag: Bool

    public init(flag: Binding<Bool>) {
        _flag = flag
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        let toggleView = UISwitch(frame: CGRect(origin: .init(x: 100, y: 100),
                                                size: .init(width: 100, height: 40)))
        toggleView.addTarget(self, action: #selector(toggle), for: .primaryActionTriggered)
        view.addSubview(toggleView)
        toggleView.isOn = flag
    }

    @objc func toggle(sender: UISwitch) {
        flag = sender.isOn
    }
}

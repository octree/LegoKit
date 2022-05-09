# LegoKit

使用声明式语法组织 UICollectionView。支持类似 SwiftUI 的 `@State`、`@Published` 和 `@StateObject`


## Installation

### Swift Package Manager

File > Swift Packages > Add Package Dependency
Add https://github.com/octree/LegoKit.git
Select "Up to Next Major" with "1.0.0"


## How to Use

### Cell 的实现

```swift
public struct ColorItem: TypedItemType {
    public typealias CellType = ColorCell
    public var id: UUID
    public var color: UIColor
    public var height: CGFloat
}

public class ColorCell: UICollectionViewCell, TypedCellType {
    public typealias Item = ColorItem

    public func update(with item: ColorItem) {
        backgroundColor = item.color
    }

    public static func layout(constraintsTo size: CGSize, with item: ColorItem) -> CGSize {
        CGSize(width: size.width, height: item.height)
    }
}
```

* id: 可以是任意 `Hashable`类型，为了给以后做动画，进行 diff 准备的预留属性。
* 其他的属性，是用来配置 Cell 的信息
* Cell 需要实现 `TypedCellType` 的两个方法
  * **update**：根据对应的 `Item` 更新 UI
  * **layout**：根据 Item 和给定的 size 信息，计算当前 Cell 的 size

### 渲染 UICollectionView

#### 配置 Lego

```swift
class ViewController: UIViewController {
    var lego: Lego {
        Lego {
            Section(id: ..., WaterfallLayout()) {
                ColorItem(...)
                ColorItem(...)
                ColorItem(...)
            }

            Section(WaterfallLayout()) {
                for elt in array {
                    ColorItem(elt)
                }
            }
        }
    }
}
```

* Lego 用于描述 **CollectionView** 中的 Section 和 Cell 的信息
* 使用类似 SwiftUI 的声明式语法构建
* 支持 `if`、`#if @available `、`for in`、`switch case`等结构

#### 渲染

```swift
class ViewController: UIViewController {
    lazy var legoRenderer: LegoRenderer = .init(lego: lego)
    override func viewDidLoad() {
        legoRenderer.render(in: view) {
            $0.backgroundColor = UIColor(white: 0.95, alpha: 1)
        }
    }

    private func reload() {
        legoRenderer.apply(lego)
    }
}
```



### 使用 @State、@StateObject 等，自动更新 CollectionView

```swift
class ViewModel: LegoObservableObject {
    @LegoPublished var items: [ColorItem] = []
    func addRandomColor() {
        items.append(.random)
    }
}

class ViewController: UIViewController, LegoContainer {
    @StateObject var viewModel = ViewModel()
    @State var flag: Bool = false
    lazy var legoRenderer: LegoRenderer = .init(lego: lego)
    var lego: Lego {
        Lego {
            Section(id: 0, layout: WaterfallLayout()) {
                if flag {
                    // ... some items.
                }
                viewModel.items
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        legoRenderer.render(in: view) {
            $0.backgroundColor = UIColor(white: 0.95, alpha: 1)
        }
    }
}
```

* 当用于配置 Lego 的数据，使用了 `@State` 或者 `@StateObject ` 时就不需要手动调用 `apply` 函数。当数据发生变动时，会自动更新 `UICollectionView`。

## License

# NorthLayout

[![Build Status](https://app.bitrise.io/app/099ef6919e27d42e/status.svg?token=Xj3O0yJCDOX-ynxtFTyJGg)](https://app.bitrise.io/app/099ef6919e27d42e)
[![Version](https://img.shields.io/cocoapods/v/NorthLayout.svg?style=flat)](http://cocoapods.org/pods/NorthLayout)
[![License](https://img.shields.io/cocoapods/l/NorthLayout.svg?style=flat)](http://cocoapods.org/pods/NorthLayout)
[![Platform](https://img.shields.io/cocoapods/p/NorthLayout.svg?style=flat)](http://cocoapods.org/pods/NorthLayout)

The fast path to autolayout views in code

## Talks

<https://speakerdeck.com/banjun/lets-start-vfl>

## Simple Usage

```swift
let iconView = UIImageView() // and customize...
let nameLabel = UILabel() // and customize...

override func loadView() {
    super.loadView()
    title = "Simple Example"
    view.backgroundColor = .white
    let autolayout = northLayoutFormat(["p": 8], [
        "icon": iconView,
        "name": nameLabel])
    autolayout("H:||[icon(==64)]") // 64pt width icon on left side with default margin
    autolayout("H:||[name]||") // full width label with default margin
    autolayout("V:||-p-[icon(==64)]-p-[name]") // stack them vertically
}
```

![](misc/ios-example.png)

See also `Example` project.

## View Level Safe Area Example

```swift
override init(frame: CGRect) {
    super.init(frame: frame)
    // autolayout respecting safe area without reference to container view controller
    let autolayout = northLayoutFormat([:], [
        "icon": iconView,
        "name": nameLabel])
    autolayout("H:||-(>=0)-[icon(==64)]-(>=0)-||") // 64pt fitting width icon with default margin
    autolayout("H:||[name]||") // fitting width label with default margin
    autolayout("V:||[icon(==64)]-[name]||") // stack them vertically
    // constrain iconView horizontal ambiguity to safe area center
    layoutMarginsGuide.centerXAnchor.constraint(equalTo: iconView.centerXAnchor).isActive = true
}
```

![](misc/northlayout-viewlevel-safearea-example.gif)

See also `Example` project.

## Advanced Example

![](misc/northlayout-advanced-example.gif)

See `Example` project.

## Features

### 📜 No Storyboards Required

Let's autolayout in code. boilerplates such as `translatesAutoresizingMaskIntoConstraints = false` and adding as subview are coded in `northLayoutFormat()`.

### ↔️ Visual Format Language

Use Visual Format Language (VFL) for layout.

[Auto Layout Guide: Visual Format Language](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html)

### ⏸ Extended Visual Format for Layout Margins & Safe Area

In addition to Apple VFL above, NorthLayout introduces `||` syntax for layout margin bounds.

```swift
// stick to side edges (i.e. screen edges for view of view controller)
autolayout("H:|[icon1]|")

// stick to side layout margins (avoids non safe areas)
autolayout("H:||[icon2]||")
```

### 📚 View Controller level & View level layout

In autolayout, there is some differences in view of view controller and independent view. `northLayoutFormat` is available for view controller and view.
You can use `|` as topLayoutGuide or bottomLayoutGuide (mainly for before iOS 11) and avoid conflicting scroll adjustments on view controllers.
You can also code layout simply without a view controller on views.

### 📱🖥 iOS & macOS

Available for UIView & NSView

## Migration to NorthLayout 5

NorthLayout 4 has supported Safe Area by translating `|` bounds as safe area layout guides by default.

NorthLayout 5 adds breaking changes that introduces `||` layout margin guides and thus `|` no longer respects Safe Area.
Choose `|` to stick to edges, or `||` to inset in layout margins or safe area.

## Installation

NorthLayout is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NorthLayout"
```

## Code Snippets

Code snippets help writing VFL activated in string literal scope.

```bash
cd (NorthLayout directory)
cp CodeSnippets/*.codesnippet ~/Library/Developer/Xcode/UserData/CodeSnippets/
```

![](misc/codesnippets-1.png)

![](misc/codesnippets-2.png)

## The Name

NorthLayout is named after where it was cocoapodized, [Lake Toya](http://en.wikipedia.org/wiki/Lake_Tōya) in the North prefecture of Japan, the setting of [Celestial Method](http://en.wikipedia.org/wiki/Celestial_Method).

## License

NorthLayout is available under the MIT license. See the LICENSE file for more info.

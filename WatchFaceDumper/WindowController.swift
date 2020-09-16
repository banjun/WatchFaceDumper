import Cocoa
import Ikemen

final class WindowController: NSWindowController, NSToolbarDelegate, NSSharingServicePickerToolbarItemDelegate {
    init(document: Document) {
        let window = NSWindow(contentViewController: ViewController(document: document))
        super.init(window: window)
        window.toolbar = NSToolbar(identifier: "WindowController") ※ {
            $0.delegate = self
            $0.allowsUserCustomization = true
        }
    }

    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.share, .space, .flexibleSpace]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.flexibleSpace, .share]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .share: return NSSharingServicePickerToolbarItem(itemIdentifier: itemIdentifier) ※ {
            $0.delegate = self
        }
        default: return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }

    func items(for pickerToolbarItem: NSSharingServicePickerToolbarItem) -> [Any] {
        [(contentViewController as! ViewController).document]
    }
}

private extension NSToolbarItem.Identifier {
    static let share: NSToolbarItem.Identifier = .init("share")
}

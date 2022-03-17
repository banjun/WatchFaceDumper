import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBAction func newDocument(_ sender: Any?) {
        let wc = NSWindowController(window: .init(contentViewController: NewDocumentViewController()))
        wc.window?.title = "New watchface"
        wc.window?.styleMask = [.titled]
        wc.showWindow(nil)
    }
}

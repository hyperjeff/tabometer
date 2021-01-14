import Cocoa

@main class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
	@IBOutlet weak var menu: NSMenu?
	@IBOutlet weak var title: NSMenuItem?
	@IBOutlet weak var quit: NSMenuItem?
	
	var statusItem: NSStatusItem?
	let fileman = FileManager.default
	var path: String = ""
	var timer: Timer?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let library = fileman.urls(for: .documentDirectory, in: .userDomainMask).first!
		path = library.appendingPathComponent("LastSession.plist").path
		
		statusItem = NSStatusBar.system.statusItem(withLength: 36)
		
		let tabInfoView = TabView(frame: NSRect(origin: .zero, size: statusItem!.button!.frame.size))
		
		if let menu = menu {
			statusItem?.menu = menu
			menu.delegate = self
			statusItem?.button?.addSubview(tabInfoView)
		}
		
		timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { t in
			self.updateCountInfoFromSafari()
		}
		
		timer?.fire()
	}
	
	func updateCountInfoFromSafari() {
		if fileman.fileExists(atPath: path) {
			do {
				let data = try Data(contentsOf: URL(fileURLWithPath: path))
				
				if PropertyListSerialization.propertyList(data, isValidFor: .binary) {
					let pls = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil)
					if let d = pls as? [String : Any],
					   let windows = d["SessionWindows"] as? [[String : Any]] {
						
						let tabs = windows.map { w in (w["TabStates"] as! [[String : Any]]).count }.reduce(0, +)
						
						if let tabView = self.statusItem?.button?.subviews.first(where: { view in view is TabView }) as? TabView {
							tabView.tabCount = tabs
							tabView.windowCount = windows.count
							tabView.updateCounts()
						}
					}
				}
			}
			catch {
				print(error.localizedDescription)
				fatalError()
			}
		}
	}
	
	@IBAction func quit(_ sender: Any) {
		timer?.invalidate()
		NSRunningApplication.current.terminate()
	}
	
	@IBAction func tabometer(_ sender: Any) {
		if let url = URL(string: "https://github.com/hyperjeff/tabometer") {
			NSWorkspace.shared.open(url)
		}
	}
}

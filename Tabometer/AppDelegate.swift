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

class TabView: NSView {
	var tabCount: Int = -1
	var windowCount: Int = -1
	
	var top: NSTextField!
	var bottom: NSTextField!
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		
		let font = NSFont(name: "Arial", size: 0.4 * frameRect.height)
		let halfHeight = frameRect.height / 2
		
		top = NSTextField(frame: NSRect(origin: CGPoint(x: 0, y: halfHeight), size: CGSize(width: frameRect.width, height: halfHeight)))
		top.isBezeled = false
		top.isBordered = false
		top.alignment = .center
		top.textColor = NSColor(named: "TabColor")
		top.font = font
		top.isSelectable = false
		top.backgroundColor = .clear
		
		bottom = NSTextField(frame: NSRect(origin: .zero, size: CGSize(width: frameRect.width, height: halfHeight)))
		bottom.alignment = .center
		bottom.textColor = NSColor(named: "WindowColor")
		bottom.isBezeled = false
		bottom.isBordered = false
		bottom.font = font
		bottom.isSelectable = false
		bottom.backgroundColor = .clear

		updateCounts()
		
		addSubview(top)
		addSubview(bottom)
	}
	
	func updateCounts() {
		top.stringValue = (tabCount < 0) ? "---" : "\(tabCount) T"
		bottom.stringValue = (windowCount < 0) ? "---" : "\(windowCount) W"
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

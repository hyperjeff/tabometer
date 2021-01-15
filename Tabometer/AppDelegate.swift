import Cocoa

@main class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
	@IBOutlet weak var menu: NSMenu?
	@IBOutlet weak var title: NSMenuItem?
	@IBOutlet weak var quit: NSMenuItem?
	
	var statusItem: NSStatusItem?
	let fileman = FileManager.default
	var lastSessionURL: URL?
	var timer: Timer?
	let sessionURLKey = "LastSession.plist"
	
	override func awakeFromNib() {
		super.awakeFromNib()
//		UserDefaults.standard.removeObject(forKey: sessionURLKey)

		statusItem = NSStatusBar.system.statusItem(withLength: 36)
		
		let tabInfoView = TabView(frame: NSRect(origin: .zero, size: statusItem!.button!.frame.size))
		
		if let menu = menu {
			statusItem?.menu = menu
			menu.delegate = self
			statusItem?.button?.addSubview(tabInfoView)
		}
		
		var wentOk = false
		
		if let bookmark = UserDefaults.standard.value(forKey: sessionURLKey) as? Data {
			do {
				var isStable = false
				lastSessionURL = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStable)
				
				startTimer()
				wentOk = true
			}
			catch {
				print(error.localizedDescription)
				fatalError()
			}
		}
		
		if !wentOk {
			setupSessionURL()
		}
	}
	
	func startTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { t in
			self.updateCountInfoFromSafari()
		}
		
		timer?.fire()
	}
	
	func setupSessionURL() {
		let openPanel = NSOpenPanel()
		openPanel.message = "Select the file ~/Library/Safari/LastSession.plist and press the [Select] button"
		openPanel.prompt = "Select"
		openPanel.nameFieldLabel = "test 1"
		openPanel.backgroundColor = .red
		openPanel.directoryURL = fileman.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Safari").appendingPathComponent("LastSession.plist")
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseDirectories = false
		openPanel.canChooseFiles = true
		
		openPanel.begin { result in
			if result == .OK,
			   let url = openPanel.url,
			   url.lastPathComponent == self.sessionURLKey {
				self.lastSessionURL = url
				self.setup(url: url)
			}
			
			self.startTimer()
		}
	}
	
	func setup(url: URL) {
		do {
			let bookmark = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
			UserDefaults.standard.setValue(bookmark, forKey: sessionURLKey)
		}
		catch {
			print(error.localizedDescription)
			fatalError()
		}
	}
	
	func updateCountInfoFromSafari() {
		if let url = lastSessionURL,
		   fileman.fileExists(atPath: url.path) {
			do {
				let requiresStop = url.startAccessingSecurityScopedResource()
				
				let data = try Data(contentsOf: url)
				
				if requiresStop { url.stopAccessingSecurityScopedResource() }
				
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
		else {
			UserDefaults.standard.removeObject(forKey: sessionURLKey)
			setupSessionURL()
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

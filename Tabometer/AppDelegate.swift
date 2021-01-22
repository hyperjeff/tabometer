import Cocoa

@main class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
	@IBOutlet weak var menu: NSMenu?
	@IBOutlet weak var title: NSMenuItem?
	@IBOutlet weak var quit: NSMenuItem?
	
	var statusItem: NSStatusItem?
	var tabInfoView: TabView!
	let fileman = FileManager.default
	var lastSessionURL: URL?
	var lastSession: LastSession?
	var timer: Timer?
	let sessionURLKey = "LastSession.plist"
	var ubiquitousStore = NSUbiquitousKeyValueStore()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		// Uncomment to reset url when testing
//		UserDefaults.standard.removeObject(forKey: sessionURLKey)

		statusItem = NSStatusBar.system.statusItem(withLength: 50)
		
		tabInfoView = TabView(frame: NSRect(origin: .zero, size: statusItem!.button!.frame.size))
		
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
				UserDefaults.standard.removeObject(forKey: sessionURLKey)
			}
		}
		
		if !wentOk {
			setupSessionURL()
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(updatePerHostInfo), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: nil)
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
			if let session = LastSession(lastSessionURL: url),
			   let tabView = self.statusItem?.button?.subviews.first(where: { view in view is TabView }) as? TabView {
				lastSession = session
				
				// for resetting while debugging:
//				for key in ubiquitousStore.dictionaryRepresentation.keys {
//					ubiquitousStore.removeObject(forKey: key)
//				}
//				ubiquitousStore.synchronize()

				if let host = Host.current().name {
					ubiquitousStore.set([session.tabCount, session.windowCount], forKey: massageHostName(host))
					ubiquitousStore.synchronize()
					updatePerHostInfo()
				}
				
				tabView.tabCount = session.tabCount
				tabView.windowCount = session.windowCount
				tabView.updateCounts()
			}
		}
		else {
			UserDefaults.standard.removeObject(forKey: sessionURLKey)
			setupSessionURL()
		}
	}
	
	@objc func updatePerHostInfo() {
		if let menu = menu {
			let ubiHosts = Set<String>(ubiquitousStore.dictionaryRepresentation.keys)
			let menuHosts = Set(menu.items
				.filter { $0.title.contains(":") }
				.map { String($0.title.split(separator: ":").first!) })
			
			var totals = (0, 0)
			for arrays in ubiHosts.map({ ubiquitousStore.array(forKey: $0) }) {
				if let counts = arrays,
				   let tabs = counts.first as? Int,
				   let windows = counts.last as? Int {
					totals.0 += tabs
					totals.1 += windows
				}
			}
			
			if 0 < totals.0 && 0 < totals.1 {
				tabInfoView.totalTabCount = totals.0
				tabInfoView.totalWindowCount = totals.1
			}
			
			let onBoth = ubiHosts.intersection(menuHosts)
			let newHosts = ubiHosts.subtracting(menuHosts)
			let oldHosts = menuHosts.subtracting(ubiHosts)
			
			for host in oldHosts {
				if let item = menu.items.first(where: { $0.title.starts(with: "\(host.localizedCapitalized):") }) {
					menu.removeItem(item)
				}
			}
			
			for host in onBoth {
				if let item = menu.items.first(where: { $0.title.starts(with: "\(host.localizedCapitalized):") }),
				   let counts = ubiquitousStore.array(forKey: host),
				   let tabs = counts.first,
				   let windows = counts.last {
					item.title = "\(host): \(tabs) T, \(windows) W"
				}
			}
			
			for host in newHosts {
				if let counts = ubiquitousStore.array(forKey: host),
				   let tabs = counts.first,
				   let windows = counts.last {
					let item = NSMenuItem(title: "\(host.localizedCapitalized): \(tabs) T, \(windows) W", action: nil, keyEquivalent: "")
					menu.insertItem(item, at: 0)
				}
			}
		}
	}
	
	func massageHostName(_ name: String) -> String {
		var out = name
		for ending in [".local"] {
			if name.hasSuffix(ending) {
				out = String(name.dropLast(ending.count))
			}
		}
		
		return out.localizedCapitalized
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

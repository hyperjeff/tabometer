import Cocoa

class TabView: NSView {
	var tabCount: Int?
	var windowCount: Int?
	var totalTabCount: Int?
	var totalWindowCount: Int?
	
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
		if let tc = tabCount, let wc = windowCount {
			if let ttc = totalTabCount, let twc = totalWindowCount {
				top.stringValue = "\(tc) / \(ttc) T"
				bottom.stringValue = "\(wc) / \(twc) W"
			}
			else {
				top.stringValue = "\(tc) T"
				bottom.stringValue = "\(wc) W"
			}
		}
		else {
			top.stringValue = "---"
			bottom.stringValue = "---"
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

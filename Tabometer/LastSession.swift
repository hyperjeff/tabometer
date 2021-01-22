import Foundation

let fileman = FileManager.default

class LastSession {
	var data: Data?
	var windows: [[String : Any]] = []
	
	var tabCount: Int {
		windows
			.map { w in (w["TabStates"] as! [[String : Any]]).count }
			.reduce(0, +)
	}
	
	var windowCount: Int {
		windows.count
	}
	
	init?(lastSessionURL url: URL) {
		do {
			let requiresStop = url.startAccessingSecurityScopedResource()
			let data = try Data(contentsOf: url)
			if requiresStop { url.stopAccessingSecurityScopedResource() }
			
			if PropertyListSerialization.propertyList(data, isValidFor: .binary) {
				let pls = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil)
				if let d = pls as? [String : Any],
				   let windowInfo = d["SessionWindows"] as? [[String : Any]] {
					windows = windowInfo
				}
			}
		}
		catch {
			print(error.localizedDescription)
			return nil
		}
	}
}

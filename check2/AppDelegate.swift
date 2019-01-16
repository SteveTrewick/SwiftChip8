
import Cocoa
import SwiftChip8EmulatorCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	var emulator = SwiftChip8Emulator()

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		if let run1path = Bundle.main.url(forResource: "run1", withExtension: "txt"),
		   let run2path = Bundle.main.url(forResource: "run2", withExtension: "txt")
		{
			if let run1 = try? String(contentsOf: run1path),
			   let run2 = try? String(contentsOf: run2path)
			{
				let r1lines = run1.components(separatedBy: .newlines)
				let r2lines = run2.components(separatedBy: .newlines)

				for (i, line) in r1lines.enumerated() {
					let x = line.split(separator: " ")[0]
					let y = r2lines[i].split(separator: " ")[0]
					print("\(i) \(x) \(r2lines[i])")
					if x != y { exit(0) }
				}

			}
		}
		// not helpful because we have timing loops and the timing loops are different,
		// so we'd need to execute in sync, yes steve, yes you would need to do that, step by step,
		// and then check what differs, which is, you know, like a thing that you could do.
		return
		let url = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("trip8.ch8")
		guard let data = try? Data(contentsOf: url) else { fatalError() }
		emulator.load(rom: Array(data), at: 0x200)
		emulator.setPC(offset: 0x200)
		
		var count = 0

		while true {
			try! emulator.step()
			count += 1
			if count % 10 == 0 { emulator.decrementTimers() }
		}
		// run them both exactly like this and lets see if that helps
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}


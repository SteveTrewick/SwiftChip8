

import Cocoa
import SwiftChip8EmulatorCore


class DisplayLink {
	
	var link    :CVDisplayLink?
	var handler : CVDisplayLinkOutputHandler?

	func createLink(screenID: CGDirectDisplayID)  {
		CVDisplayLinkCreateWithCGDisplay(screenID, &link)
	}
	
	func start()  {
		CVDisplayLinkSetOutputHandler(link!, handler!)
		CVDisplayLinkStart(link!)
	}
	
	func stop() {
		CVDisplayLinkStop(link!)
	}
}


class ViewController: NSViewController {

	let displayLink = DisplayLink()
	var emulator    = SwiftChip8Emulator()
	
	override func viewDidAppear() {
		// ok, that's how we do that, then
		// NB we can't get the screen/window untill viewDidAppear,
		// didLoad will not cut it as they're not set yet.
		
		
		let url = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("BC_test.ch8")
		guard let data = try? Data(contentsOf: url) else { fatalError() }
		
		
		emulator.load(rom: Array(data), at: 0x200)
		emulator.setPC(offset: 0x200)
		
		
		let idx = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
		if let id = self.view.window?.screen?.deviceDescription[idx] as? CGDirectDisplayID {
			displayLink.createLink(screenID: id)
			displayLink.handler = { (link, now, out, flags, context) in
				let fps = 1 / CVDisplayLinkGetActualOutputVideoRefreshPeriod(link)
				do {
					try self.emulator.emulate(at: 500, fps: fps)
				}
				catch {
					CVDisplayLinkStop(link)
					print(error)
				}
				return 0
			}
			displayLink.start()

		}
	
	}

	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override var representedObject: Any? {
		didSet {
		
		}
	}


}







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
	
	@IBOutlet weak var imgview: NSImageView!
	
	
	override func viewDidAppear() {
		
//		let url = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("trip8.ch8")
		guard let url = Bundle.main.url(forResource: "trip8", withExtension: "ch8") else {
			fatalError("couldn't find ROM URL")
		}
		guard let data = try? Data(contentsOf: url) else {
			fatalError("couldn't load ROM")
		}


		

		emulator.load(rom: Array(data), at: 0x200)
		emulator.setPC(offset: 0x200)
		
		
		let idx = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
		if let id = self.view.window?.screen?.deviceDescription[idx] as? CGDirectDisplayID {
			displayLink.createLink(screenID: id)
			displayLink.handler = { (link, now, out, flags, context) in
				let fps = 1 / CVDisplayLinkGetActualOutputVideoRefreshPeriod(link)
				do {
					
					let cgimage = try self.emulator.render()
					DispatchQueue.main.async {
						self.imgview.image = NSImage(cgImage: cgimage, size: NSSize(width: 640, height: 320))
					}
					try self.emulator.emulate(at: 700, fps: fps)
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





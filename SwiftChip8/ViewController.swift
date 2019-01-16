

import Cocoa



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
	
	override func viewDidAppear() {
		// ok, that's how we do that, then
		// NB we can't get the screen/window untill viewDidAppear,
		// didLoad will not cut it as they're not set yet.
		
		let idx = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
		if let id = self.view.window?.screen?.deviceDescription[idx] as? CGDirectDisplayID {
			displayLink.createLink(screenID: id)
			displayLink.handler = { (link, now, out, flags, context) in
				let fps = 1 / CVDisplayLinkGetActualOutputVideoRefreshPeriod(link)
				print (fps)
				return 0
			}
			displayLink.start()
			DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
				self.displayLink.stop()
			}
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





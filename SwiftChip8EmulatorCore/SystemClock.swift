
import Foundation



class SystemClock {
	
	let queue = DispatchQueue(label: "com.domain.app.timer", qos: .userInteractive)
	let timer : DispatchSourceTimer
	
	init(hz: Double) {
		let seconds = 1 / hz
		timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
		timer.schedule(deadline: .now(), repeating: seconds, leeway: .nanoseconds(0))
	}
	
	func start() { timer.resume() }
	func stop()  { timer.cancel() }
	
	var tick : (()->Void)? = nil {
		didSet {
			timer.setEventHandler(handler: tick)
		}
	}
}


import Foundation

class Timer {
	
	var count: UInt8 = 0x00
	
	func load(_ register:Byte) {
		count = register.value
	}
	
	func decrement() {
		if count > 0 { count -= 1}
	}
}

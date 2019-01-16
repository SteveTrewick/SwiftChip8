
import Foundation



class ProgramCounter {
	
	let step   = UInt16(2)
	var stack  = Stack<UInt16>()
	
	var pointer: UInt16 = 0x0200
	
	func jmp(_ address: UInt16) throws {
		if address == pointer {
			throw EmulationError.loopHalt
		}
		self.pointer = address
	}
	
	func push() {
		stack.push(pointer + step)
	}
	
	func pop() throws {
		guard let ret = stack.pop() else { throw EmulationError.emptyStack  }
		pointer = ret
	}
	
	func skip(_ cond: Bool) {
		pointer += step * (cond ? 2 : 1)
	}
	
	func increment() {
		pointer += step
	}
	
}

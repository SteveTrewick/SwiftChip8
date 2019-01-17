
import Foundation



class ProgramCounter {
	
	let step   = 2
	var stack  = Stack<Word>()
	
	var pointer = Word(value:0x200)
	
	func jmp(_ address: Word) throws {
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

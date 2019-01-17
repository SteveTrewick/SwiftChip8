
import Foundation


// should be a struct, also then can +=
struct ProgramCounter {
	
	let step   = 2
	var stack  = Stack<Word>()
	
	var pointer = Word(value:0x200)
	
	mutating func jmp(_ address: Word) throws {
		if address == pointer {
			throw EmulationError.loopHalt
		}
		self.pointer = address
	}
	
	mutating func push() {
		stack.push(pointer + step)
	}
	
	mutating func pop() throws {
		guard let ret = stack.pop() else { throw EmulationError.emptyStack  }
		pointer = ret
	}
	
	mutating func skip(_ cond: Bool) {
		pointer += step * (cond ? 2 : 1)
	}
	
	mutating func increment() {
		pointer += step
	}
	
}

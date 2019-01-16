
import Foundation


class MemoryIndex {
	var pointer: UInt16 = 0x0000
	func load(_ offset: UInt16) {
		pointer = offset
	}
	func add(_ register: Register) {
		pointer += UInt16(register.value)
	}
	static func +(lhs: MemoryIndex, rhs: UInt8) -> Int {  // should probably be byte
		return Int(lhs.pointer) + Int(rhs)
	}
	static func ..<(lhs: MemoryIndex, rhs: Int) -> Range<Int> {  // necessary
		return Int(lhs.pointer)..<rhs
	}
}

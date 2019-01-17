
import Foundation

struct Word : Comparable, ExpressibleByIntegerLiteral {
	
	var value: UInt16
	
	init(value: UInt16 = 0 ) {
		self.value = value
	}
	
	init(integerLiteral value: UInt16) {
		self.value = value
	}
	
	
	static func +=(lhs: inout Word, rhs: Word) {
		lhs.value += rhs.value
	}
	static func +=(lhs: inout Word, rhs: Byte) {
		lhs.value += UInt16(rhs.value)
	}
	static func +=(lhs: inout Word, rhs: Int) {
		lhs.value += UInt16(rhs)
	}
	static func +(lhs: Word, rhs: Byte) -> Word {
		return Word(value: lhs.value + UInt16(rhs.value))
	}
	static func +(lhs: Word, rhs: UInt8) -> Word {
		return Word(value: lhs.value + UInt16(rhs))
	}
	static func +(lhs: Word, rhs: Int) -> Word {
		return Word(value: lhs.value + UInt16(rhs))
	}
	
	static func ==(lhs: Word, rhs: Word) -> Bool {
		return lhs.value == rhs.value
	}
	
	static func < (lhs: Word, rhs: Word) -> Bool {
		return lhs.value < rhs.value
	}

}

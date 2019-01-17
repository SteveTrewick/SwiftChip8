
import Foundation


struct Register : Equatable {
	
	var value   :UInt8
	private var overflow:UInt8
	
	var overflowed : Register {
		return Register(value: overflow)
	}
	
	init(value: UInt8 = 0, overflow: UInt8 = 0) {
		self.value     = value
		self.overflow  = overflow
	}
	
	
	mutating func load(_ value: UInt8) {
		self.value    = value
		self.overflow = 0
	}
	
 	mutating func load(_ timer: Timer) {
		self.value    = timer.count
		self.overflow = 0
	}

	
	
	static func ==(lhs: Register, rhs: Register) -> Bool {
		return lhs.value == rhs.value
	}
	
	static func |=( lhs: inout Register, rhs: Register) {
		lhs.value |= rhs.value
		lhs.overflow = 0
	}
	
	static func ^=(lhs: inout Register, rhs: Register) {
		lhs.value ^= rhs.value
		lhs.overflow = 0
	}
	
	static func &=(lhs: inout Register, rhs: Register) {
		lhs.value &= rhs.value
		lhs.overflow = 0
	}
	
	static func +=(lhs: inout Register, rhs: Register) {
		let (result, overflow) = lhs.value.addingReportingOverflow(rhs.value)
		lhs.value = result
		lhs.overflow = overflow ? 1 : 0
	}
	
	static func -=(lhs: inout Register, rhs: Register) {
		let (result, overflow) = lhs.value.subtractingReportingOverflow(rhs.value)
		lhs.value = result
		lhs.overflow = overflow ? 0 : 1
	}
	
	static func -=(lhs: inout Register, rhs: Int) {
		let (result, overflow) = lhs.value.subtractingReportingOverflow(UInt8(rhs))
		lhs.value = result
		lhs.overflow = overflow ? 0 : 1
	}
	
	static func -(lhs: inout Register, rhs: Register) -> Register {
		let (result, overflow) = lhs.value.subtractingReportingOverflow(rhs.value)
		return Register(value: result, overflow: overflow ? 0 : 1)
	}
	
	static func <<(lhs: inout Register, rhs: Int) -> Register {
		return  Register(value: lhs.value << rhs)
	}
	static func >>(lhs: inout Register, rhs: Int) -> Register {
		return Register(value:lhs.value >> rhs)
	}
	
	
	static func ==(lhs: inout Register, rhs: UInt8) -> Bool {  // should probably be byte
		return lhs.value == rhs
	}
	
	static func !=(lhs: inout Register, rhs: UInt8) -> Bool {  // should pobably be byte
		return lhs.value != rhs
	}
	
	
	static func +=(lhs: inout Register, rhs: UInt8)  {        // should probably be byte
		let (result, _) = lhs.value.addingReportingOverflow(rhs)
		lhs.value = result
	}

	
	static func +(lhs: UInt16, rhs: Register) -> UInt16 {  // should probably be address
		return lhs + UInt16(rhs.value)
	}

	static func *(lhs: Register, rhs: Int) -> Word {
		return Word(value: UInt16(lhs.value) * UInt16(rhs))
	}
	
	static func &(lhs: Register, rhs: Int) -> Register {
		return Register(value: lhs.value & UInt8(rhs))
	}
}


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
	static func +=(lhs: inout Word, rhs: Register) {
		lhs.value += UInt16(rhs.value)
	}
	static func +=(lhs: inout Word, rhs: Int) {
		lhs.value += UInt16(rhs)
	}
	static func +(lhs: Word, rhs: Register) -> Word {
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

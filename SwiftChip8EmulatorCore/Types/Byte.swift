
import Foundation


struct Byte : Equatable {
	
	var value   :UInt8
	private var overflow:UInt8
	
	var overflowed : Byte {
		return Byte(value: overflow)
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

	
	
	static func ==(lhs: Byte, rhs: Byte) -> Bool {
		return lhs.value == rhs.value
	}
	
	static func |=( lhs: inout Byte, rhs: Byte) {
		lhs.value |= rhs.value
		lhs.overflow = 0
	}
	
	static func ^=(lhs: inout Byte, rhs: Byte) {
		lhs.value ^= rhs.value
		lhs.overflow = 0
	}
	
	static func &=(lhs: inout Byte, rhs: Byte) {
		lhs.value &= rhs.value
		lhs.overflow = 0
	}
	
	static func +=(lhs: inout Byte, rhs: Byte) {
		let (result, overflow) = lhs.value.addingReportingOverflow(rhs.value)
		lhs.value = result
		lhs.overflow = overflow ? 1 : 0
	}
	
	static func -=(lhs: inout Byte, rhs: Byte) {
		let (result, overflow) = lhs.value.subtractingReportingOverflow(rhs.value)
		lhs.value = result
		lhs.overflow = overflow ? 0 : 1
	}
	
	static func -=(lhs: inout Byte, rhs: Int) {
		let (result, overflow) = lhs.value.subtractingReportingOverflow(UInt8(rhs))
		lhs.value = result
		lhs.overflow = overflow ? 0 : 1
	}
	
	static func -(lhs: inout Byte, rhs: Byte) -> Byte {
		let (result, overflow) = lhs.value.subtractingReportingOverflow(rhs.value)
		return Byte(value: result, overflow: overflow ? 0 : 1)
	}
	
	static func <<(lhs: inout Byte, rhs: Int) -> Byte {
		return  Byte(value: lhs.value << rhs)
	}
	static func >>(lhs: inout Byte, rhs: Int) -> Byte {
		return Byte(value:lhs.value >> rhs)
	}
	
	
	static func ==(lhs: inout Byte, rhs: UInt8) -> Bool {  // should probably be byte
		return lhs.value == rhs
	}
	
	static func !=(lhs: inout Byte, rhs: UInt8) -> Bool {  // should pobably be byte
		return lhs.value != rhs
	}
	
	
	static func +=(lhs: inout Byte, rhs: UInt8)  {        // should probably be byte
		let (result, _) = lhs.value.addingReportingOverflow(rhs)
		lhs.value = result
	}

	
	static func +(lhs: UInt16, rhs: Byte) -> UInt16 {  // should probably be address
		return lhs + UInt16(rhs.value)
	}

	static func *(lhs: Byte, rhs: Int) -> Word {
		return Word(value: UInt16(lhs.value) * UInt16(rhs))
	}
	
	static func &(lhs: Byte, rhs: Int) -> Byte {
		return Byte(value: lhs.value & UInt8(rhs))
	}
}



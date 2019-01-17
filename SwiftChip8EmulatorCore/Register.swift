
import Foundation


class Register : Equatable {
	
	var value   :UInt8
	var overflow:UInt8
	
	var bits:BitCollection<UInt8> { return BitCollection(value: self.value) }
	
	init(value:UInt8, overflow: UInt8 = 0) {
		self.value     = value
		self.overflow  = overflow
	}
	
	
	func load(_ value: UInt8) {
		self.value    = value
		self.overflow = 0
	}
	
 	func load(_ timer: Timer) {
		self.value    = timer.count
		self.overflow = 0
	}

	
	
	static func ==(lhs: Register, rhs: Register) -> Bool {
		return lhs.value == rhs.value
	}
	
	static func |=(lhs: Register, rhs: Register) {
		lhs.value |= rhs.value
	}
	
	static func ^=(lhs: Register, rhs: Register) {
		lhs.value ^= rhs.value
	}
	
	static func &=(lhs: Register, rhs: Register) {
		lhs.value &= rhs.value
	}
	
	static func +=(lhs: Register, rhs: Register) {
		let (result, overflow) = lhs.value.addingReportingOverflow(rhs.value)
		lhs.value = result
		lhs.overflow = overflow ? 1 : 0
	}
	
	static func -=(lhs: Register, rhs: Register) {
		let (result, overflow) = lhs.value.subtractingReportingOverflow(rhs.value)
		lhs.value = result
		lhs.overflow = overflow ? 0 : 1
	}
	
	static func -(lhs: Register, rhs: Register) -> Register {
		let (result, overflow) = lhs.value.subtractingReportingOverflow(rhs.value)
		return Register(value: result, overflow: overflow ? 0 : 1)
	}
	
	static func <<(lhs: Register, rhs: Int) -> UInt8 {
		return  lhs.value << rhs
	}
	static func >>(lhs: Register, rhs: Int) -> UInt8 {
		return lhs.value >> rhs
	}
	
	
	static func ==(lhs: Register, rhs: UInt8) -> Bool {  // should probably be byte
		return lhs.value == rhs
	}
	
	static func !=(lhs: Register, rhs: UInt8) -> Bool {  // should pobably be byte
		return lhs.value != rhs
	}
	
	
	static func +=(lhs: Register, rhs: UInt8)  {        // should probably be byte
		let (result, _) = lhs.value.addingReportingOverflow(rhs)
		lhs.value = result
	}

	
	static func +(lhs: UInt16, rhs: Register) -> UInt16 {  // should probably be address
		return lhs + UInt16(rhs.value)
	}

	static func *(lhs: Register, rhs: UInt16) -> UInt16 {  // wut?
		return UInt16(lhs.value) + rhs                       // fails if I take this out : $0.register[$0.opcode.x].load( $0.delaytimer )
	}                                                      // wtaf?
}

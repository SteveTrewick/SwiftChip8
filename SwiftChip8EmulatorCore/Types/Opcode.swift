
import Foundation


struct Opcode {
	let word   : UInt16
	var code   : UInt8  { return UInt8((word >> 12) & 0x0F) }
	var address: Word   { return Word(value: (word & 0x0FFF)) }
	var x      : UInt8  { return UInt8((word >>  8) & 0x0F) }
	var y      : UInt8  { return UInt8((word >>  4) & 0x0F) }
	var byte   : Byte  { return Byte(value: UInt8(word & 0x00FF)) }
	var nibble : Byte  { return Byte(value: UInt8(word & 0x000F)) }
}



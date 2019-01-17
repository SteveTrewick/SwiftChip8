
import Foundation



public class MachineState {
	
	let register     = Registers()
	let memory       = Memory()
	let memoryindex  = MemoryIndex()
	let pc           = ProgramCounter()
	var opcode       = Opcode(word: 0x0000)
	let key          = Keys()
	let delaytimer   = Timer()
	let soundtimer   = Timer()
	let spritebuffer = SpriteBuffer(width: 64, height: 32)
	var halted       = false
	
	public init(){} // ffs
	
	// doing these in line made the swift type checker very cross
	func rendersprite(pixels: Slice<Memory>, height:UInt8, x: Register, y: Register) -> UInt8 {
		let result =  spritebuffer.draw(sprite: Sprite (
			bytes : Array(pixels),
			height: height,
			x	    : x.value,
			y     : y.value
		))
		return result
	}
	
	func bcd(_ register: Register) -> [UInt8] {
		let byte = register.value
		return [byte / 100, (byte / 10) % 10, byte % 10]
	}
	
	func waitkey(_ byte: UInt8) {
		
	}
	
	func rand(_ byte: UInt8) -> UInt8 {
		return UInt8.random(in: 0...255) & byte
	}

}

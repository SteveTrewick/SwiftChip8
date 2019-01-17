
import Foundation



public class MachineState {
	
	let register     = Registers()
	let memory       = Memory()
	var memoryindex  = Word()//MemoryIndex()
	let pc           = ProgramCounter()
	var opcode       = Opcode(word: 0x0000)
	let key          = Keys()
	var delaytimer   = Register()//Timer()
	var soundtimer   = Register()//Timer()
	let spritebuffer = SpriteBuffer(width: 64, height: 32)
	var halted       = false
	
	public init(){} // ffs
	
	// doing these in line made the swift type checker very cross
	func rendersprite(pixels: Slice<Memory>, height:UInt8, x: Register, y: Register) -> Register {
		let result =  spritebuffer.draw(sprite: Sprite (
			bytes : pixels.map{UInt8($0.value)},
			height: height,
			x	    : x.value,
			y     : y.value
		))
		return result
	}
	
	func bcd(_ register: Register) -> [Register] {
		let byte = register.value
		return [byte / 100, (byte / 10) % 10, byte % 10].map{Register(value:$0)}
	}
	
	func waitkey(_ byte: UInt8) {
		
	}
	
	func rand(_ byte: Register) -> Register {
		return Register(value: UInt8.random(in: 0...255) & byte.value)
	}

}

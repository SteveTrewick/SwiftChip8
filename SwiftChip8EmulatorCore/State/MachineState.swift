
import Foundation



public class MachineState {
	
	let register     = Registers()
	let memory       = Memory()
	var memoryindex  = Word()//MemoryIndex()
	let pc           = ProgramCounter()
	var opcode       = Opcode(word: 0x0000)
	let key          = Keys()
	var delaytimer   = Byte()//Timer()
	var soundtimer   = Byte()//Timer()
	let spritebuffer = SpriteBuffer(width: 64, height: 32)
	var halted       = false
	
	public init(){} // ffs
	
	// doing these in line made the swift type checker very cross
	func rendersprite(pixels: Slice<Memory>, height:UInt8, x: Byte, y: Byte) -> Byte {
		let result =  spritebuffer.draw(sprite: Sprite (
			bytes : pixels.map{UInt8($0.value)},
			height: height,
			x	    : x.value,
			y     : y.value
		))
		return result
	}
	
	func bcd(_ register: Byte) -> [Byte] {
		let byte = register.value
		return [byte / 100, (byte / 10) % 10, byte % 10].map{Byte(value:$0)}
	}
	
	func waitkey(_ byte: UInt8) {
		
	}
	
	func rand(_ byte: Byte) -> Byte {
		return Byte(value: UInt8.random(in: 0...255) & byte.value)
	}

}


import Foundation


// ok, I think we can use that instead of raw dict and index by reg/byte
struct MachineDescription : ExpressibleByDictionaryLiteral {
	
	var elements:[UInt8 : (MachineState) throws -> Void] = [:]
	
	init(dictionaryLiteral elements: (Register, (MachineState) throws -> Void)...) {
		elements.forEach { element in self.elements[element.0.value] = element.1 }
	}
	
	subscript(_ key: Register)  -> ((MachineState) throws -> Void)? {
		get {
			return elements[key.value]
		}
	}
	

}


public class SwiftChip8Emulator {

	let core    =  Chip8SystemDescription.EmulatorCore
	let machine =  MachineState()
	let gpu     =  SwiftChip8GPU()
	
	public init() {
		self.machine.memory.load(romdata: Chip8SystemDescription.Font, offset: 0x0000)
	}

	
	public func step() throws {
		
		let hi         = machine.memory[machine.pc.pointer    ]
		let lo         = machine.memory[machine.pc.pointer + 1]
		let opcode     = (UInt16(hi.value) << 8) + UInt16(lo.value)
		
		machine.opcode = Opcode(word: opcode)
		
		guard let execute = core[machine.opcode.code] else {
			throw EmulationError.badInstruction
		}
		
		try execute(machine)
	}
	
	
	// call on a timer synced to display refresh
	public func emulate(at hz:Double, fps:Double) throws {
		
		machine.delaytimer -= 1
		machine.soundtimer -= 1
		
		let steps = Int(hz / fps)
		
		for _ in 0..<steps {
			if machine.halted { break }
			try step()
		}
	}
	
	public func load(rom:[UInt8], at address:UInt16) {
		machine.memory.load(romdata: rom, offset: address)
	}
	
	public func setPC(offset: UInt16) {
		machine.pc.pointer = Word(value:offset)
	}
	
	public func render() throws -> CGImage {
		return try gpu.render(buffer: machine.spritebuffer)
	}

}

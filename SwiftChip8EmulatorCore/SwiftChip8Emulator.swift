
import Foundation


public typealias MachineDescription = [UInt8 : (MachineState) throws -> Void]



public class SwiftChip8Emulator {

	let core    =  Chip8SystemDescription.EmulatorCore
	let machine =  MachineState()
	let gpu     =  SwiftChip8GPU()
	
	public init() {
		//self.core    = Chip8SystemDescription.EmulatorCore
		//self.machine = MachineState()
		self.machine.memory.load(romdata: Chip8SystemDescription.Font, offset: 0x0000)
	}

	
	public func step() throws {
		
		let hi         = machine.memory[Int(machine.pc.pointer)    ]
		let lo         = machine.memory[Int(machine.pc.pointer) + 1]
		let opcode     = (UInt16(hi) << 8) + UInt16(lo)
		
		machine.opcode = Opcode(word: opcode)
		
		guard let execute = core[machine.opcode.code] else {
			throw EmulationError.badInstruction
		}
		
		try execute(machine)
	}
	
	
	// call on a timer synced to display refresh
	public func emulate(at hz:Double, fps:Double) throws {
		
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
		machine.pc.pointer = offset
	}
	
	public func render() throws -> CGImage {
		return try gpu.render(buffer: machine.spritebuffer)
	}

}

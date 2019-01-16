
import Foundation


public typealias MachineDescription = [UInt8 : (MachineState) throws -> Void]



public class SwiftChip8Emulator {

	let machinecore  : [UInt8 : (MachineState) throws -> Void]
	let machinestate : MachineState
	
	public init(machinecore: [UInt8 : (MachineState) throws -> Void], machinestate: MachineState) {
		self.machinecore  = machinecore
		self.machinestate = machinestate
	}

	
	func step() throws {
		
		let hi         = machinestate.memory[Int(machinestate.pc.pointer)    ]
		let lo         = machinestate.memory[Int(machinestate.pc.pointer) + 1]
		let opcode     = (UInt16(hi) << 8) + UInt16(lo)
		
		machinestate.opcode = Opcode(word: opcode)
		
		guard let execute = machinecore[machinestate.opcode.code] else {
			throw EmulationError.badInstruction
		}
		
		try execute(machinestate)
	}
	
	

}

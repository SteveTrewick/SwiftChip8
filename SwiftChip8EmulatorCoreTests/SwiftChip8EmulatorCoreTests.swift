
import XCTest
@testable import SwiftChip8EmulatorCore

class SwiftChip8EmulatorCoreTests: XCTestCase {

	var emulator : SwiftChip8Emulator!
	let core     =  Chip8SystemDescription.EmulatorCore
	var machine  :  MachineState!
	
	override func setUp() {
		emulator = SwiftChip8Emulator()
		machine  = MachineState()
		machine.pc.pointer = 0x200
	}

	override func tearDown() {

	}

	func execute() {
		let execute = core[machine.opcode.code]!
		try! execute(machine)
	}

	// ok, just how do we go about doing the tests?
	func test_jmp() {
		
		machine.opcode = Opcode(word: 0x1abc) // jmp abc
		execute()
		
		XCTAssert(machine.pc.pointer == 0x0abc)

	}
	

	func test_call() {
		machine.opcode = Opcode(word: 0x2abc)
		execute()
		// stack top should be 0x002
		// pc should be 0x0abc
		XCTAssert(machine.pc.pointer     == 0xabc)
		XCTAssert(machine.pc.stack.peek! == 0x202)
	}
	
	func test_skip_immediate_true() {
		// skip next if r0 == ff
		machine.opcode = Opcode(word: 0x30ff)
		machine.register[0].load(0xff)
		execute()
		XCTAssert(machine.pc.pointer == 0x204)
	}

	func test_skip_immediate_false() {
		// skip next if r0 == ff, which it isn't.
		machine.opcode = Opcode(word: 0x30ee)
		machine.register[0].load(0xff)
		execute()
		XCTAssert(machine.pc.pointer == 0x202)
	}
	
	func test_skip_not_immediate_true() {
		machine.opcode = Opcode(word: 0x40ee)
		machine.register[0].load(0xff)
		execute()
		XCTAssert(machine.pc.pointer == 0x204)
	}
	
	func test_skip_not_immediate_false() {
		machine.opcode = Opcode(word: 0x40ff)
		machine.register[0].load(0xff)
		execute()
		XCTAssert(machine.pc.pointer == 0x202)
	}
	
	func test_skip_equal_registers_true() {
		machine.opcode = Opcode(word: 0x50f0)
		machine.register[0].load(0xee)
		machine.register[0xf].load(0xee)
		execute()
		XCTAssert(machine.pc.pointer == 0x204)
	}
	
	func test_skip_equal_registers_false() {
		machine.opcode = Opcode(word: 0x50f0)
		machine.register[0].load(0xee)
		machine.register[0xf].load(0xef)
		execute()
		XCTAssert(machine.pc.pointer == 0x202)
	}
	
	func test_load_immediate() {
		// load 0xab to rd
		machine.opcode = Opcode(word: 0x6dab)
		execute()
		XCTAssert(machine.register[0xd] == 0xab)
		XCTAssert(machine.pc.pointer    == 0x202)
	}
	
	func test_add_immediate() {
		// add 7 to r 0xc
		machine.opcode = Opcode(word: 0x7c07)
		machine.register[0xc].load(5)
		execute()
		XCTAssert(machine.register[0xc] == 12)
		XCTAssert(machine.pc.pointer == 0x202)
	}
	
	func test_set_regx_regy() {
		machine.opcode = Opcode(word: 0x8ab0)
		machine.register[0xa].load(0x00)
		machine.register[0xb].load(0xfe)
		execute()
		XCTAssert(machine.register[0xa] == 0xfe)
		XCTAssert(machine.pc.pointer    == 0x202)
	}
	
	
}

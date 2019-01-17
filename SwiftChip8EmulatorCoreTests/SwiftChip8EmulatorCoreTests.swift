
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

	
	
	func test_ret() {
		machine.opcode     = Opcode(word: 0x00ee)
		machine.pc.pointer = 0x400
		machine.pc.push()
		execute()
		XCTAssert(machine.pc.pointer == 0x402)
	}
	
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
	
	func test_reg_or() {
		machine.opcode = Opcode(word: 0x8ab1)
		machine.register[0xa].load(0x12)
		machine.register[0xb].load(0xfe)
		execute()
		XCTAssert(machine.register[0xa] == 0x12 | 0xfe)
		XCTAssert(machine.pc.pointer    == 0x202)
	}
	
	func test_reg_and() {
		machine.opcode = Opcode(word: 0x8ab2)
		machine.register[0xa].load(0x12)
		machine.register[0xb].load(0xfe)
		execute()
		XCTAssert(machine.register[0xa] == 0x12 & 0xfe)
		XCTAssert(machine.pc.pointer    == 0x202)
	}
	
	func test_reg_xor() {
		machine.opcode = Opcode(word: 0x8ab3)
		machine.register[0xa].load(0x12)
		machine.register[0xb].load(0xfe)
		execute()
		XCTAssert(machine.register[0xa] == 0x12 ^ 0xfe)
		XCTAssert(machine.pc.pointer    == 0x202)
	}
	
	func test_reg_add() {
		machine.opcode = Opcode(word: 0x8ab4)
		machine.register[0xa].load(0x12)
		machine.register[0xb].load(0x0e)
		execute()
		XCTAssert(machine.register[0xa] == 0x12 + 0x0e)
		XCTAssert(machine.pc.pointer    == 0x202)
	}
	
	func test_reg_sub_no_overflow() {
		machine.opcode = Opcode(word: 0x8ab5)  //ra - rb
		machine.register[0xa].load(25)
		machine.register[0xb].load(13)
		execute()
		XCTAssert(machine.register[0xa] == 25 - 13)
		XCTAssert(machine.register[0xf] == 1)
		XCTAssert(machine.pc.pointer    == 0x202)
	}
	
	func test_reg_sub_overflow() {
		machine.opcode = Opcode(word: 0x8ab5)  //ra - rb
		machine.register[0xa].load(13)
		machine.register[0xb].load(25)
		execute()
		XCTAssert(machine.register[0xa] == 13 &- 25)
		XCTAssert(machine.register[0xf] == 0)
		XCTAssert(machine.pc.pointer    == 0x202)
	}
	
	// ok, the shift instructions, lets get a bit more explicit
	let unshifted_msb  :UInt8 = 0b10000100
	let unshifted_lsb  :UInt8 = 0b00010001
	let unshifted      :UInt8 = 0b00110100
	let shift_right    :UInt8 = 0b00011010
	let shift_left     :UInt8 = 0b01101000
	let shift_right_lsb:UInt8 = 0b00001000
	let shift_left_msb :UInt8 = 0b00001000
	
	func test_shr_lsb() {
		machine.opcode = Opcode(word: 0x8d06)
		machine.register[0xd].load(unshifted_lsb)
		execute()
		XCTAssert(machine.register[0xd] == shift_right_lsb)
		XCTAssert(machine.register[0xf] == 0x1)
		XCTAssert(machine.pc.pointer    == 0x202)
	}
	
	func test_shr_no_lsb() {
		machine.opcode = Opcode(word: 0x8d06)
		machine.register[0xd].load(unshifted)
		execute()
		XCTAssert(machine.register[0xd] == shift_right)
		XCTAssert(machine.register[0xf] == 0x0)
		XCTAssert(machine.pc.pointer    == 0x202)
	}
	
	func test_shl_msb() {
		machine.opcode = Opcode(word: 0x8d0e)
		machine.register[0xd].load(unshifted_msb)
		execute()
		XCTAssert(machine.register[0xd] == shift_left_msb)
		XCTAssert(machine.register[0xf] == 0x1)
		XCTAssert(machine.pc.pointer    == 0x202)
	}
	
	
	func test_shl__no_msb() {
		machine.opcode = Opcode(word: 0x8d0e)
		machine.register[0xd].load(unshifted)
		execute()
		XCTAssert(machine.register[0xd] == shift_left)
		XCTAssert(machine.register[0xf] == 0x0)
		XCTAssert(machine.pc.pointer    == 0x202)
	}
	
	
	func test_reg_subn_no_overflow() {
		machine.opcode = Opcode(word:0x8347)  //r3 = r4 - r3
		machine.register[3].load(12)
		machine.register[4].load(25)
		execute()
		XCTAssert(machine.register[3  ] == 13)
		XCTAssert(machine.register[0xf] ==  1)
		XCTAssert(machine.pc.pointer    == 0x202)
	}
	
	func test_reg_subn_overflow() {
		machine.opcode = Opcode(word:0x8347)  //r3 = r4 - r3
		machine.register[3].load(24)
		machine.register[4].load(12)
		execute()
		XCTAssert(machine.register[3  ] == UInt8(12) &- UInt8(24))
		XCTAssert(machine.register[0xf] == 0)
		XCTAssert(machine.pc.pointer == 0x202)
	}


	func test_skip_reg_not_equal_true() {
		machine.opcode        = Opcode(word:0x9ab0) // SNE a,b : skip if a != b
		machine.register[0xa] = Register(value: 5)
		machine.register[0xb] = Register(value: 6)
		execute()
		XCTAssert(machine.pc.pointer == 0x204)
	}
	
	func test_skip_reg_not_equal_false() {
		machine.opcode        = Opcode(word:0x9ab0) // SNE a,b : skip if a != b
		machine.register[0xa] = Register(value: 5)
		machine.register[0xb] = Register(value: 5)
		execute()
		XCTAssert(machine.pc.pointer == 0x202)
	}
	
	func test_load_memory_address() {  // LD I, addr
		machine.opcode = Opcode(word:0xa123)
		execute()
		XCTAssert(machine.memoryindex.value == 0x123)
		XCTAssert(machine.pc.pointer        == 0x202)
	}

	func test_jmp_relative() {  // JP r0, addr : jump relative to reg 0
		machine.opcode      = Opcode(word:0xb123)
		machine.register[0] = Register(value:0x12)
		execute()
		XCTAssert(machine.pc.pointer == 0x123 + 0x12)
	}
	
	// rnd, is it possible to test that ? meh
	func test_rnd() {
		machine.opcode = Opcode(word:0xcaff)
		execute()
		XCTAssert(machine.pc.pointer == 0x202)
	}
	// yes, its possible to test that it oincrements the fucking pc,
	// which it wasnt. gargh!
	// sprite drawing, this might be tricky, will come back for it
	
	// skip key - not even implmented yet, forgot about that
	
	func test_set_delay() {  // and FFS make these registers will you
		machine.opcode = Opcode(word:0xf215) // LD DT, rx
		machine.register[2] = Register(value:0xff)
		execute()
		XCTAssert(machine.delaytimer.value == 0xff)
		XCTAssert(machine.pc.pointer == 0x202)
	}
	
	func test_set_sound_timer() {  // LD ST, rx
		machine.opcode      = Opcode(word:0xf218)
		machine.register[2] = Register(value:0xff)
		execute()
		XCTAssert(machine.soundtimer.value == 0xff)
		XCTAssert(machine.pc.pointer       == 0x202)
	}
	
	func test_add_reg_to_memindex() { // ADD I, rx
		machine.opcode      = Opcode(word:0xf31e)
		machine.register[3] = Register(value:0xfe)
		machine.memoryindex.value = 1
		execute()
		XCTAssert(machine.memoryindex.value == 0xff)
		XCTAssert(machine.pc.pointer          == 0x202)
	}
	
	func test_load_memindex_font_sprite() {  // LD F, x
		machine.opcode = Opcode(word: 0xfe29)
		machine.register[0xe] = Register(value: 0x2)
		execute()
		XCTAssert(machine.memoryindex.value == 10)
		XCTAssert(machine.pc.pointer          == 0x202)
	}
	
	func test_bcd() {
		machine.opcode              = Opcode(word:0xfa33)
		machine.register[0xa]       = Register(value: 0xff)
		machine.memoryindex.value = 0
		execute()
		XCTAssert(Array(machine.memory[0..<3]) == [Register(value:2), Register(value:5), Register(value:5)])
		XCTAssert(machine.pc.pointer == 0x202)
	}
	
	func test_store_reg() {
		let bytes = (0x0...0xf).map { Register(value: $0) }
		for byte in bytes {
			machine.register[byte.value] = byte
		}
		machine.opcode = Opcode(word: 0xff55)
		machine.memoryindex.value = 0x0
		execute()
		XCTAssert(Array<Register>(machine.memory[0x0...0xf]) == bytes)
		XCTAssert(machine.pc.pointer == 0x202)
	}
	
	func test_load_reg() {
		let values = (0x0...0xf).map{Register(value:$0)}
		for byte in values {
			machine.memory[Word(value: UInt16(byte.value))] = byte
		}
		machine.opcode              = Opcode(word: 0xff65)
		machine.memoryindex.value = 0
		execute()
		for byte in values {
			XCTAssert(machine.register[byte.value] == byte)
		}
		XCTAssert(machine.pc.pointer == 0x202)
	}
	
//	func test_this() {
//		machine.memory[0..<2] = [1,2].map{Register(value:$0)}
//	}
	
	// so a huge issue I had that was I had registers as class rather struct, and they should
	// be value types.
	// hopefully I'm not that stupid again, but just in case ...
	
	func test_reg_is_value_type() {
		let reg_x = Register(value: 0x10)
		var reg_y = Register(value: 0x20)
		
		reg_y.value = 0x30
		
		XCTAssert(reg_x.value == 0x10)
		
	}
	
	
}



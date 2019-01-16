
import Foundation


struct Stack<T> {
	var stack:[T] = []
	mutating func push(_ item: T) { stack.append(item)     }  // O(1)
	mutating func pop() -> T?     { return stack.popLast() }  // O(1)
	var peek:T?                   { return stack.last      }
}


struct BitCollection<T:FixedWidthInteger>  {
	
	let value:T
	
	subscript(_ index: Int) -> UInt8{
		get {
			precondition(((T.bitWidth - 1) - index) > -1)
			let shift = (T.bitWidth - 1) - index
			return UInt8((value >> shift) & 0x1)
		}
	}

}

//extension BitCollection : Sequence {
//	
//	struct BitCollectionIteraror : IteratorProtocol {
//		
//		private let value : T
//		private var shift = Int(T.bitWidth) - 1
//		
//		init(value:T) { self.value = value }
//		
//		mutating func next() -> UInt8? {
//			if shift < 0 { return nil } else {
//				defer { shift -= 1 }
//				return UInt8((value >> shift) & 0x1)
//			}
//		}
//	}
//	func makeIterator() -> BitCollectionIteraror {
//		return BitCollectionIteraror(value: value)
//	}
//}




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
		print("lhs: \(lhs.value), rhs:\(rhs.value)")
		let (result, overflow) = lhs.value.subtractingReportingOverflow(rhs.value)
		print("result: \(result), overflow: \(overflow)")
		lhs.value = result
		lhs.overflow = overflow ? 0 : 1
		print("lhs.value: \(lhs.value), lhs.overflow: \(lhs.overflow)")
	}
	
	static func <<(lhs: Register, rhs: Int) -> UInt8 {
		return  lhs.value >> rhs
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
		lhs.value += rhs
	}

	
	static func +(lhs: UInt16, rhs: Register) -> UInt16 {  // should probably be address
		return lhs + UInt16(rhs.value)
	}

	static func *(lhs: Register, rhs: UInt16) -> UInt16 {  // wut?
		return UInt16(lhs.value) + rhs                       // fails if I take this out : $0.register[$0.opcode.x].load( $0.delaytimer )
	}                                                      // wtaf?
}



class ProgramCounter {
	
	let step   = UInt16(2)
	var stack  = Stack<UInt16>()
	
	var pointer: UInt16 = 0x0200
	
	func jmp(_ address: UInt16) throws {
		if address == pointer {
			throw EmulationError.loopHalt
		}
		self.pointer = address
	}
	
	func push() {
		stack.push(pointer + step)
	}
	
	func pop() throws {
		guard let ret = stack.pop() else { throw EmulationError.emptyStack  }
		pointer = ret
	}
	
	func skip(_ cond: Bool) {
		pointer += step * (cond ? 2 : 1)
	}
	
	func increment() {
		pointer += step
	}
	
}

class Registers {
	
	// see what you did there? that's the same register 16 times.
	var values : [Register]//(repeating: Register(value: 0), count: 16)
	
	init() {
		values = [Register]()
		for _ in 0...15 {
			values.append(Register(value: 0x00))
		}
	}
	
	subscript(_ index: UInt8) -> Register {
	
		get {
			//print("reg get \(index)")
			//for (i,reg) in values.enumerated() { print("\(String(format:"%02x",i)) \(String(format:"%02x", reg.value))") }
			return values[Int(index)]
		}
		set {
			//print("reg set \(index)")
			//for (i,reg) in values.enumerated() { print("\(String(format:"%02x",i)) \(String(format:"%02x", reg.value))") }
			values[Int(index)] = newValue
		}
	}
}



class Keys {
	
	var values = Array<Bool>(repeating: false, count:0xf)
	
	subscript(_ register: Register) -> Bool {
		get { return values[Int(register.value)] }
	}
	
	subscript(_ hexkey: UInt8) -> Bool {
		get {return values[Int(hexkey)]}
		set { values[Int(hexkey)] = newValue }
	}
}



struct Opcode {
	let word   : UInt16
	var code   : UInt8  { return UInt8((word >> 12) & 0x0F) }
	var address: UInt16 { return (word & 0x0FFF) }
	var x      : UInt8  { return UInt8((word >>  8) & 0x0F) }
	var y      : UInt8  { return UInt8((word >>  4) & 0x0F) }
	var byte   : UInt8  { return UInt8(word & 0x00FF) }
	var nibble : UInt8  { return UInt8(word & 0x000F) }
}


class MemoryIndex {
	var pointer: UInt16 = 0x0000
	func load(_ offset: UInt16) {
		pointer = offset
	}
	func add(_ register: Register) {
		pointer += UInt16(register.value)
	}
	static func +(lhs: MemoryIndex, rhs: UInt8) -> Int {  // should probably be byte
		return Int(lhs.pointer) + Int(rhs)
	}
	static func ..<(lhs: MemoryIndex, rhs: Int) -> Range<Int> {  // necessary
		return Int(lhs.pointer)..<rhs
	}
}

class Timer {
	var count: UInt8 = 0x00
	func load(_ register:Register) {
		count = register.value
	}
}

class Memory : Collection {
	
	
	
	typealias Index   = Int
	typealias Element = UInt8
	
	var contents = ContiguousArray<UInt8>(repeating: 0x00, count: 4096)
	
	func load( _ offset: Int, _ register:Register) {
		contents[offset] = register.value
	}

	func load( _ bytes:[UInt8], _ index:MemoryIndex) {
		for (offset, byte) in bytes.enumerated() {
			contents[Int(index.pointer) + offset] = byte
		}
	}
	
	func load(romdata: [UInt8], offset: UInt16) {
		for (idx, byte) in romdata.enumerated() {
			contents[Int(offset) + idx] = byte
		}
	}
	
	subscript(position: Index) -> Element {
		get {
			precondition( position < contents.count )
			return contents[position]
		}
		set(value) {
			contents[position] = value
		}
	}
	
	var startIndex:Index { return 0 }
	var endIndex  :Index { return contents.count }
	func index(after i: Int) -> Int {
		return i + 1
	}
	// ok, we can slice and dice that'n now.
}


struct Sprite {
	
	let bytes : [UInt8]
	let x     : Int
	let y     : Int
	let height: UInt8
	
	init(bytes: [UInt8], height: UInt8, x: UInt8, y: UInt8) {
		self.bytes  = bytes
		self.x      = Int(x)
		self.y      = Int(y)
		self.height = height
	}
	
}

class SpriteBuffer {
	
	let height   : Int
	let width    : Int
	var contents : ContiguousArray<UInt8>
	
	init(width:Int, height:Int) {
		self.width    = width
		self.height   = height
		self.contents = ContiguousArray<UInt8>(repeating:0x0, count: width * height)
	}
	
	func cls() {
		self.contents = ContiguousArray<UInt8>(repeating:0x0, count: width * height)
	}
	
	private func unpack(_ uint8: UInt8) -> [UInt8] {
		var bits : [UInt8] = []
		
		for shift in stride(from: 7, to: -1, by: -1) {
			let bit = (uint8 >> shift) & 0x1
			bits.append(bit)
		}
		return bits
	}
	
	
	func draw(sprite: Sprite) -> UInt8 {
		
		var collision : UInt8 = 0
		
		for (r, row) in sprite.bytes.map(unpack).enumerated() {
			
			for (c, column) in row.enumerated() {
			
				let index = (sprite.x + c + ((sprite.y + r) * 64)) % 2048
				
				if contents[index] == 1 && (contents[index] ^ column) == 0 { collision = 1 }  // check collision
				
				contents[index] ^= column
			}
		}
		return collision
	}
	
	
	func dumpFormatted() {
		for i in stride(from: 0, to: width * height, by: width) {
			print(contents[i...i+62].map { $0 == 1 ? "*" : "." }.joined())
		}
	}
	
}


class Machine {
	
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
	
	// doing these in line made the swift type checker very cross
	func rendersprite(pixels: Slice<Memory>, height:UInt8, x: Register, y: Register) -> UInt8 {
		let result =  spritebuffer.draw(sprite: Sprite (
			bytes : Array(pixels),
			height: height,
			x	    : x.value,
			y     : y.value
		))
		spritebuffer.dumpFormatted()
		return result
	}
	
	func bcd(_ register: Register) -> [UInt8] {
		let byte = register.value
		return [byte / 100, (byte / 10) % 10, byte % 10]
	}
	
	func waitkey(_ byte: UInt8) {
		
	}

}


enum EmulationError : Error {
	case badInstruction
	case loopHalt
	case emptyStack
}






// ok, in theory we should be able to put this in a harness and run it some, so
// lets find out.


class Harness {
	
	let core    : [UInt8 : (Machine) throws -> Void]
	let machine : Machine
	
	init(core: [UInt8 : (Machine) throws -> Void], machine: Machine) {
		self.core    = core
		self.machine = machine
	}
	
	
	func emulate() throws {
		while true {
			let hi         = machine.memory[Int(machine.pc.pointer)    ]
			let lo         = machine.memory[Int(machine.pc.pointer) + 1]
			let opcode     = (UInt16(hi) << 8) + UInt16(lo)
			machine.opcode = Opcode(word: opcode)
			
			print("\(String(format: "%04x", machine.pc.pointer)) \(String(format: "%04x", opcode))")
			
			if machine.opcode.word == 0x00e0 {
				machine.spritebuffer.cls()
				machine.pc.increment()
				continue
			}
			
			if machine.opcode.word == 0x0ee {
				try machine.pc.pop()
				continue
			}
			guard let execute = core[machine.opcode.code] else {
				throw EmulationError.badInstruction
			}
			do {
				try execute(machine)
			}
			catch {
				throw error
			}
		
		}
	
	}
}


class Chip8SystemDescription {
	
	// Chip8 base font glyphs
	
	static let Font :[UInt8] = [
			0xF0, 0x90, 0x90, 0x90, 0xF0, //0
			0x20, 0x60, 0x20, 0x20, 0x70, //1
			0xF0, 0x10, 0xF0, 0x80, 0xF0, //2
			0xF0, 0x10, 0xF0, 0x10, 0xF0, //3
			0x90, 0x90, 0xF0, 0x10, 0x10, //4
			0xF0, 0x80, 0xF0, 0x10, 0xF0, //5
			0xF0, 0x80, 0xF0, 0x90, 0xF0, //6
			0xF0, 0x10, 0x20, 0x40, 0x40, //7
			0xF0, 0x90, 0xF0, 0x90, 0xF0, //8
			0xF0, 0x90, 0xF0, 0x10, 0xF0, //9
			0xF0, 0x90, 0xF0, 0x90, 0x90, //A
			0xE0, 0x90, 0xE0, 0x90, 0xE0, //B
			0xF0, 0x80, 0x80, 0x80, 0xF0, //C
			0xE0, 0x90, 0x90, 0x90, 0xE0, //D
			0xF0, 0x80, 0xF0, 0x80, 0xF0, //E
			0xF0, 0x80, 0xF0, 0x80, 0x80  //F
	]
	
	
	
	static let EmulatorCore : [UInt8 : (Machine) throws -> Void] = [
	
		
			0x1 : { try
							$0.pc.jmp($0.opcode.address) },
			
			0x2 : { $0.pc.push()
							try
							$0.pc.jmp($0.opcode.address) },
			
			0x3 : { $0.pc.skip( $0.register[$0.opcode.x] == $0.opcode.byte ) },
			
			0x4 : { $0.pc.skip( $0.register[$0.opcode.x] != $0.opcode.byte ) },
			
			0x5 : { $0.pc.skip( $0.register[$0.opcode.x] == $0.register[$0.opcode.y] ) },
			
			0x6 : { $0.register[$0.opcode.x].load($0.opcode.byte)
							$0.pc.increment()
						},
			
			0x7 : { $0.register[$0.opcode.x] += $0.opcode.byte
							$0.pc.increment()
						},
			
			0x8: { try [
								0x0 : { $0.register[$0.opcode.x]  = $0.register[$0.opcode.y] },
								0x1 : { $0.register[$0.opcode.x] |= $0.register[$0.opcode.y] },
								0x2 : { $0.register[$0.opcode.x] &= $0.register[$0.opcode.y] },
								0x3 : { $0.register[$0.opcode.x] ^= $0.register[$0.opcode.y] },
								
								0x4 : { $0.register[$0.opcode.x] += $0.register[$0.opcode.y]
												$0.register[0xf        ].load($0.register[$0.opcode.x].overflow)
								},
								0x5 : { $0.register[$0.opcode.x] -= $0.register[$0.opcode.y]
												$0.register[0xf        ].load($0.register[$0.opcode.x].overflow)
								},
								0x6 : { $0.register[0xf        ].load($0.register[$0.opcode.x].bits[7])
												$0.register[$0.opcode.x].load($0.register[$0.opcode.x] >> 1)
								},
								0x7 : { $0.register[$0.opcode.y] -= $0.register[$0.opcode.x]
												$0.register[0xf        ].load($0.register[$0.opcode.y].overflow)
								},
								0xe : { $0.register[0xf        ].load($0.register[$0.opcode.x].bits[0])
												$0.register[$0.opcode.x].load($0.register[$0.opcode.x] << 1)
								}
				
							][$0.opcode.nibble, default: { _ in throw EmulationError.badInstruction }]($0)
							$0.pc.increment()
						},
			
			0x9 : { $0.pc.skip( $0.register[$0.opcode.x] != $0.register[$0.opcode.y] )},
			
			0xa : { $0.memoryindex.load( $0.opcode.address)
							$0.pc.increment()
						},
			
			0xb : { try $0.pc.jmp ( $0.opcode.address + $0.register[0] ) },
			

			0xd: {	$0.register[0xf].load(0)
							$0.register[0xf].load( $0.rendersprite (
								pixels: $0.memory[$0.memoryindex..<$0.memoryindex + $0.opcode.nibble],
								height: $0.opcode.nibble,
								x     : $0.register[$0.opcode.x],
								y     : $0.register[$0.opcode.y]
							))
							$0.pc.increment()
					 },
			
			0xe : { try [
								0x9e: { $0.pc.skip( $0.key[ $0.register[$0.opcode.x] ] == true  )},
								0xa1: { $0.pc.skip( $0.key[ $0.register[$0.opcode.x] ] == false )}
				
							][$0.opcode.byte, default: { _ in throw EmulationError.badInstruction }]($0)
						},

			0xf : { try [
								0x07: { $0.register[$0.opcode.x].load( $0.delaytimer ) },
								0x0a: { $0.waitkey($0.opcode.x)},
								0x15: { $0.delaytimer.load ( $0.register[$0.opcode.x] )},
								0x18: { $0.soundtimer.load ( $0.register[$0.opcode.x] )},
								0x1e: { $0.memoryindex.add ( $0.register[$0.opcode.x] )},
								0x29: { $0.memoryindex.load( $0.register[$0.opcode.x] * 5)},
								0x33: { $0.memory.load     ( $0.bcd($0.register[$0.opcode.x]), $0.memoryindex ) },
								
								0x55: {
									for idx in 0...$0.opcode.x {
										$0.memory.load($0.memoryindex + idx, $0.register[idx])
									}
								},
								
								0x65: {
									for idx in 0...$0.opcode.x {
										$0.register[idx].load( $0.memory[$0.memoryindex + idx] )
									}
								}
				
							][$0.opcode.byte, default: { _ in throw EmulationError.badInstruction }]($0)
							$0.pc.increment()
						}
	]

}



// ok, lets load up a test rom then
let url = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("BC_test.ch8")
guard let data = try? Data(contentsOf: url) else { fatalError() }



let machine = Machine()
machine.memory.load(romdata: Chip8SystemDescription.Font,   offset: 0x000)
machine.memory.load(romdata: Array(data), offset: 0x200)
machine.pc.pointer = 0x200

let harness = Harness(core: Chip8SystemDescription.EmulatorCore, machine: machine)
do {
	try harness.emulate()
}
catch {
	print("execution terminated : \(error)")
}


// alrighty then, that works pretty nicely indeed now the most
// ovbious bugs are out of it. I like this code, this one's
// the keeper.

// so what can we do to make it better?

// for a start, non exity error handling, so we need to signal
// back up when something is wrong, including the loop halt
// so let's start by setting up a proper error and a handler
// to just print some stuff out

// ok, next.

// need a better emu loop. Timer. Wait for keys, etc.
// lets put a halt flag in there.



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

extension BitCollection : Sequence {
	
	struct BitCollectionIteraror : IteratorProtocol {
		
		private let value : T
		private var shift = Int(T.bitWidth) - 1
		
		init(value:T) { self.value = value }
		
		mutating func next() -> UInt8? {
			if shift < 0 { return nil } else {
				defer { shift -= 1 }
				return UInt8((value >> shift) & 0x1)
			}
		}
	}
	func makeIterator() -> BitCollectionIteraror {
		return BitCollectionIteraror(value: value)
	}
}




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
	
	static func &=(lhs: Register, rhs: Register) {
		lhs.value &= rhs.value
	}
	
	static func +=(lhs: Register, rhs: Register) {
		let (result, overflow) = lhs.value.addingReportingOverflow(rhs.value)
		lhs.value = result
		lhs.overflow = overflow ? 1 : 0
	}
	
	static func -=(lhs: Register, rhs: Register) {
		let (result, overflow) = lhs.value.subtractingReportingOverflow(rhs.value)
		lhs.value = result
		lhs.overflow = overflow ? 0 : 1
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
	
	func jmp(_ address: UInt16) { self.pointer = address }
	
	func push() {
		stack.push(pointer + step)
	}
	
	func pop() {
		guard let ret = stack.pop() else {fatalError("whoops")}
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
	var values = [Register](repeating: Register(value: 0), count: 0xf)
	
	subscript(_ index: UInt8) -> Register {
	
		get { return values[Int(index)]     }
		set { values[Int(index)] = newValue }
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

	// doing these in line made the swift type checker very cross
	func rendersprite(pixels: Slice<Memory>, height:UInt8, x: UInt8, y:UInt8) -> UInt8 {
		return spritebuffer.draw(sprite: Sprite(
			bytes : Array(pixels),
			height: height,
			x	    : x,
			y     : y
		))
	}
	
	func bcd(_ byte: UInt8) -> [UInt8] {
		return [byte / 100, (byte / 10) % 10, byte % 10]
	}
	
	func waitkey(_ byte: UInt8) {
		
	}

}

enum Bad : Error { case egg }

let description : [UInt8:(Machine) throws -> Void] = [
	
	
		0x1 : { $0.pc.jmp($0.opcode.address) },
		
		0x2 : { $0.pc.push()
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
							0x0 : { $0.register[$0.opcode.x]  = $0.register[$0.opcode.y] },
							0x1 : { $0.register[$0.opcode.x] |= $0.register[$0.opcode.y] },
							0x3 : { $0.register[$0.opcode.x] &= $0.register[$0.opcode.y] },
							
							0x4 : { $0.register[$0.opcode.x] += $0.register[$0.opcode.y]
											$0.register[0xf        ].load($0.register[$0.opcode.x].overflow)
							},
							0x5 : { $0.register[$0.opcode.x] -= $0.register[$0.opcode.y]
											$0.register[0xf        ].load($0.register[$0.opcode.x].overflow)
							},
							0x6 : { $0.register[0xf        ].load($0.register[$0.opcode.y].bits[8])
											$0.register[$0.opcode.x].load($0.register[$0.opcode.y] >> 1)
							},
							0x7 : { $0.register[$0.opcode.y] -= $0.register[$0.opcode.x]
											$0.register[0xf        ].load($0.register[$0.opcode.y].overflow)
							},
							0xe : { $0.register[0xf        ].load($0.register[$0.opcode.y].bits[1])
											$0.register[$0.opcode.x].load($0.register[$0.opcode.y] << 1)
							}
			
						][$0.opcode.nibble, default: { machine in throw Bad.egg }]($0)
						$0.pc.increment()
					},
		
		0x9 : { $0.pc.skip( $0.register[$0.opcode.x] != $0.register[$0.opcode.y] )},
		
		0xa : { $0.memoryindex.load( $0.opcode.address)
						$0.pc.increment()
					},
		
		0xb : { $0.pc.jmp ( $0.opcode.address + $0.register[0] ) },
		

		0xd: {	$0.register[0xf].load(0)
						$0.register[0xf].load( $0.rendersprite (
							pixels: $0.memory[$0.memoryindex..<$0.memoryindex + $0.opcode.nibble],
							height: $0.opcode.nibble,
							x     : $0.opcode.x,
							y     : $0.opcode.y
						))
				 },
		
		0xe : { try [
							0x9e: { $0.pc.skip( $0.key[ $0.register[$0.opcode.x] ] == true  )},
							0xa1: { $0.pc.skip( $0.key[ $0.register[$0.opcode.x] ] == false )}
			
						][$0.opcode.byte, default: { machine in throw Bad.egg }]($0)
					},

		0xf : { try [
							0x07: { $0.register[$0.opcode.x].load( $0.delaytimer ) },
							0x0a: { $0.waitkey($0.opcode.x)},
							0x15: { $0.delaytimer.load ( $0.register[$0.opcode.x] )},
							0x18: { $0.soundtimer.load ( $0.register[$0.opcode.x] )},
							0x1e: { $0.memoryindex.add ( $0.register[$0.opcode.x] )},
							0x29: { $0.memoryindex.load( $0.register[$0.opcode.x] * 5)},
							0x33: { $0.memory.load     ( $0.bcd($0.opcode.x), $0.memoryindex ) },
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
			
						][$0.opcode.byte, default: { machine in throw Bad.egg }]($0)
						$0.pc.increment()
					}
]




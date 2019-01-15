
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
		
		private let value:T
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
	
	
	func load(_ value:UInt8) {
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
	
	
	static func ==(lhs: Register, rhs: UInt8) -> Bool {
		return lhs.value == rhs
	}
	
	static func !=(lhs: Register, rhs: UInt8) -> Bool {
		return lhs.value != rhs
	}
	
	
	static func +=(lhs: Register, rhs: UInt8)  {
		lhs.value += rhs
	}

	
	static func +(lhs: UInt16, rhs: Register) -> UInt16 {
		return lhs + UInt16(rhs.value)
	}

	static func *(lhs: Register, rhs: UInt16) -> UInt16 {
		return UInt16(lhs.value) + rhs
	}
}



class ProgramCounter {
	
	let step   = UInt16(2)
	var stack  = Stack<UInt16>()
	
	var pointer:UInt16 = 0x0200
	
	func jmp(_ address:UInt16) { self.pointer = address }
	
	func push() {
		stack.push(pointer + step)
	}
	
	func pop() {
		guard let ret = stack.pop() else {fatalError("whoops")}
		pointer = ret
	}
	
	func skip(_ cond:Bool) {
		pointer += step * (cond ? 2 : 1)
	}
	
	func increment() {
		pointer += step
	}
	
}

class Registers {
	var values = [Register](repeating:Register(value: 0), count: 0xf)
	
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
	
	subscript(_ hexkey:UInt8) -> Bool {
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
	var pointer:UInt16 = 0x0000
	func load(_ offset: UInt16) {
		pointer = offset
	}
	func add(_ register:Register) {
		pointer += UInt16(register.value)
	}
	static func +(lhs:MemoryIndex, rhs:UInt8) -> UInt16 {
		return lhs.pointer + UInt16(rhs)
	}
}

class Timer {
	var count:UInt8 = 0x00
	func load(_ register:Register) {
		count = register.value
	}
}

class Memory {
	var contents = ContiguousArray<UInt8>(repeating: 0x00, count: 4096)
	func load( _ offset: UInt16, _ register:Register) {
		contents[Int(offset)] = register.value
	}
	subscript(_ index:UInt16) -> UInt8 {
		get {
			return contents[Int(index)]
		}
	}
}

class Machine {
	
	let register = Registers()
	let memory  =  Memory()
	let memoryindex   = MemoryIndex()
	let pc   = ProgramCounter()
	var opcode   = Opcode(word:0x0000)
	let key  = Keys()
	let delaytimer   = Timer()
	let soundtimer   = Timer()

}


// ok, that's a bit of infrastructure to start with,
// lets have a look at what we can do here

let description : [UInt8:(Machine)->Void] = [
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
	
	0x08: { switch $0.opcode.nibble {
						case 0x0 : $0.register[$0.opcode.x]  = $0.register[$0.opcode.y]
						case 0x1 : $0.register[$0.opcode.x] |= $0.register[$0.opcode.y]
						case 0x3 : $0.register[$0.opcode.x] &= $0.register[$0.opcode.y]

						case 0x4 : $0.register[$0.opcode.x] += $0.register[$0.opcode.y]
						           $0.register[0xf        ].load($0.register[$0.opcode.x].overflow)

						case 0x5 : $0.register[$0.opcode.x] -= $0.register[$0.opcode.y]
						           $0.register[0xf        ].load($0.register[$0.opcode.x].overflow)

						case 0x6 : $0.register[0xf        ].load($0.register[$0.opcode.y].bits[8])
						           $0.register[$0.opcode.x].load($0.register[$0.opcode.y] >> 1)
		
						case 0x7 : $0.register[$0.opcode.y] -= $0.register[$0.opcode.x]
						           $0.register[0xf        ].load($0.register[$0.opcode.y].overflow)
		
						case 0xe : $0.register[0xf        ].load($0.register[$0.opcode.y].bits[1])
						           $0.register[$0.opcode.x].load($0.register[$0.opcode.y] << 1)
		
						default  : fatalError() // add some nice error handling stuff pls.
					}
					$0.pc.increment()
				},
	
	0x9 : { $0.pc.skip( $0.register[$0.opcode.x] != $0.register[$0.opcode.y] )},
	
	0xa : { $0.memoryindex.load( $0.opcode.address)
		      $0.pc.increment()
				},
	0xb : { $0.pc.jmp ( $0.opcode.address + $0.register[0] ) },
	//0xd // we'll come back for this after
	0xe : { switch $0.opcode.byte {
						case 0x9e: $0.pc.skip( $0.key[ $0.register[$0.opcode.x] ] == true  )
						case 0xa1: $0.pc.skip( $0.key[ $0.register[$0.opcode.x] ] == false )
						default  : fatalError() // add lovely error handling shortly
				}},
	0xf : { switch $0.opcode.byte {
						case 0x07: $0.register[$0.opcode.x].load( $0.delaytimer )
						//case 0x0a: // key wait, patch later
						case 0x15: $0.delaytimer.load ( $0.register[$0.opcode.x] )
						case 0x18: $0.soundtimer.load ( $0.register[$0.opcode.x] )
						case 0x1e: $0.memoryindex.add ( $0.register[$0.opcode.x] )
						case 0x29: $0.memoryindex.load( $0.register[$0.opcode.x] * 5)
		
						case 0x55:
							for idx in 0...$0.opcode.x {
								$0.memory.load($0.memoryindex + idx, $0.register[idx])
							}
						case 0x65:
							for idx in 0...$0.opcode.x {
								$0.register[idx].load( $0.memory[$0.memoryindex + idx] )
							}
						default: fatalError() // add lovely error handling shortly
					}
					$0.pc.increment()
				}
]


// ok, so, not only does that turn out to be viable, it's also pretty nice to look at
// and it was a joy to write as well! So that's nice.

enum Bad : Error {
	case egg, biscuit
}

let testdec : [UInt8:(Machine) throws -> Void] = [
	0x8: { try [                     // that syntax even looks good.
			0x5 : {_ in print("yay")},
			0x6 : {_ in print("woo") }
		
		][$0.opcode.nibble, default: {_ in throw Bad.egg} ]($0)
	}
]
// oh yes, yes we can do that
// ok, so you CAN do that, but then what about the case where the subcode is not recognised?
// tricky.

// BWAHAHAHAHAHAHAHAAHAAAAAA I am fucking leet today.

let mac = Machine()
mac.opcode = Opcode(word: 0x8357)
try testdec[0x8]?(mac)


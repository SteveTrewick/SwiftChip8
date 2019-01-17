
import Foundation


class Memory : Collection {
	
	typealias Index   = Word
	typealias Element = Byte
	
	var contents = ContiguousArray<Byte>()
	
	init()
	{
		for _ in 0..<4096 {
			contents.append(Byte())
		}
	}
	
	func load( _ offset: Int, _ register:Byte) {
		contents[offset] = register
	}

	func load( _ bytes:[Byte], _ index: Word) {
		for (offset, byte) in bytes.enumerated() {
			contents[Int(index.value) + offset] = byte
		}
	}
	
	func load(romdata: [UInt8], offset: UInt16) {
		for (idx, byte) in romdata.enumerated() {
			contents[Int(offset) + idx] = Byte(value: byte)
		}
	}
	
	subscript(position: Word) -> Element {
		get {
			precondition( position.value < contents.count )
			return contents[Int(position.value)]
		}
		set(value) {
			contents[Int(position.value)] = value
		}
	}
	
	
	
	var startIndex:Index { return Word(value: 0) }
	var endIndex  :Index { return Word(value: UInt16(contents.count)) }
	func index(after i: Word) -> Word {
		return Word(value: i.value + 1)
	}
}


import Foundation


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
}

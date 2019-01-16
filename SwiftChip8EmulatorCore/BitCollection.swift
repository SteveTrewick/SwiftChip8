
import Foundation


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

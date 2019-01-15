
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



// ok, is this doing what I think it is, and why didn't I know that in
// advance.

let bits = BitCollection<UInt8>(value: 0x80)
for bit in bits { print(bit) }
print()

for i in 0...7 { print(bits[i]) }

// [0] = msb, as it should, really

// ok, whappen this

func bcd(_ byte: UInt8) -> [UInt8] {
	return [byte / 100, (byte / 10) % 10, byte % 10]
}

let b = bcd(0x8a)
print(b)


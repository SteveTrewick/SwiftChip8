
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

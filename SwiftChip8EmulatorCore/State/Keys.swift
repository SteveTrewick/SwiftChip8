
import Foundation


class Keys {
	
	var values = Array<Bool>(repeating: false, count:0xf)
	
	subscript(_ register: Byte) -> Bool {
		get { return values[Int(register.value)] }
	}
	
	subscript(_ hexkey: UInt8) -> Bool {
		get {return values[Int(hexkey)]}
		set { values[Int(hexkey)] = newValue }
	}
}

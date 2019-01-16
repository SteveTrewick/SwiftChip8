
import Foundation


class Registers {
	
	var values : [Register]
	
	init() {
		values = [Register]()
		for _ in 0...15 {
			values.append(Register(value: 0x00))
		}
	}
	
	subscript(_ index: UInt8) -> Register {
		get { return values[Int(index)]     }
		set { values[Int(index)] = newValue }
	}
}

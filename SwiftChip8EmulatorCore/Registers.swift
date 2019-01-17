
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

extension Registers : CustomStringConvertible {
	var description: String {
		var desc = ""
		
		for (i,value) in values.enumerated() {
			desc += String(format:"%02x", i) + ":[" + String(format:"%02x", value.value) + "], "
		}
		
		return desc
	}
}

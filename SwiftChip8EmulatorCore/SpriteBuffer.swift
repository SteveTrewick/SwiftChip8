
import Foundation


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
	
	
	func draw(sprite: Sprite) -> Byte {
		
		var collision : UInt8 = 0
		
		for (r, row) in sprite.bytes.map(unpack).enumerated() {
			for (c, column) in row.enumerated() {
			
				let index = ((sprite.x + c) + ((sprite.y + r) * 64)) % 2048
				if contents[index] == 1 && (contents[index] ^ column) == 0 { collision = 1 }  // check collision
				contents[index] ^= column
			}
		}
		return Byte(value: collision)
	}

	func dumpFormatted() {
		for i in stride(from: 0, to: width * height, by: width) {
			print(contents[i...i+62].map { $0 == 1 ? "*" : "." }.joined())
		}
	}
}

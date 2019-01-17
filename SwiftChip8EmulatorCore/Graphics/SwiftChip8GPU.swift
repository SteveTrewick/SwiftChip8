
import Foundation




class SwiftChip8GPU {

	let colorspace = CGColorSpaceCreateDeviceGray()
	
	func generateContext(width: Int, height: Int) -> CGContext? {
		return CGContext(
			data            : nil,
			width           : width,
			height          : height,
			bitsPerComponent: 8,
			bytesPerRow     : width,
			space           : colorspace,
			bitmapInfo      : CGImageAlphaInfo.none.rawValue
		)
	}
	
	func render(buffer: SpriteBuffer) throws -> CGImage {
		
		guard let context     = generateContext(width: buffer.width, height: buffer.height) else { fatalError("GPU bork") }
		guard let pixelbuffer = context.data?.bindMemory(to: UInt8.self, capacity: buffer.contents.count) else { fatalError("GPU bork") }
		
		for i in 0..<buffer.contents.count {
			pixelbuffer[i] = buffer.contents[i] == 0 ? 0 : 255
		}
		
		guard let image = context.makeImage() else { throw EmulationError.gpubork } // make these throw
	
		return image
	}
	
	
}


import Foundation

enum EmulationError : Error {
	case badInstruction
	case loopHalt
	case emptyStack
	case gpubork
}



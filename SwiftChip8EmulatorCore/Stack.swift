
import Foundation


struct Stack<T> {
	var stack:[T] = []
	mutating func push(_ item: T) { stack.append(item)     }  // O(1)
	mutating func pop() -> T?     { return stack.popLast() }  // O(1)
	var peek:T?                   { return stack.last      }
}



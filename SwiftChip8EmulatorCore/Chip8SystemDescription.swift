
import Foundation

class Chip8SystemDescription {
	
	// Chip8 base font glyphs
	
	static let Font :[UInt8] = [
			0xF0, 0x90, 0x90, 0x90, 0xF0, //0
			0x20, 0x60, 0x20, 0x20, 0x70, //1
			0xF0, 0x10, 0xF0, 0x80, 0xF0, //2
			0xF0, 0x10, 0xF0, 0x10, 0xF0, //3
			0x90, 0x90, 0xF0, 0x10, 0x10, //4
			0xF0, 0x80, 0xF0, 0x10, 0xF0, //5
			0xF0, 0x80, 0xF0, 0x90, 0xF0, //6
			0xF0, 0x10, 0x20, 0x40, 0x40, //7
			0xF0, 0x90, 0xF0, 0x90, 0xF0, //8
			0xF0, 0x90, 0xF0, 0x10, 0xF0, //9
			0xF0, 0x90, 0xF0, 0x90, 0x90, //A
			0xE0, 0x90, 0xE0, 0x90, 0xE0, //B
			0xF0, 0x80, 0x80, 0x80, 0xF0, //C
			0xE0, 0x90, 0x90, 0x90, 0xE0, //D
			0xF0, 0x80, 0xF0, 0x80, 0xF0, //E
			0xF0, 0x80, 0xF0, 0x80, 0x80  //F
	]
	
	
	
	static let EmulatorCore : [UInt8 : (MachineState) throws -> Void] = [
	
			0x0 : { try [
								0xe0 : { $0.spritebuffer.cls()
												 $0.pc.increment()
											 },
								0xee : { try $0.pc.pop() }
				
							][$0.opcode.byte, default: { _ in throw EmulationError.badInstruction }]($0)
						},
			0x1 : { try
							$0.pc.jmp($0.opcode.address) },
			
			0x2 : { $0.pc.push()
							try
							$0.pc.jmp($0.opcode.address) },
			
			0x3 : { $0.pc.skip( $0.register[$0.opcode.x] == $0.opcode.byte ) },
			
			0x4 : { $0.pc.skip( $0.register[$0.opcode.x] != $0.opcode.byte ) },
			
			0x5 : { $0.pc.skip( $0.register[$0.opcode.x] == $0.register[$0.opcode.y] ) },
			
			0x6 : { $0.register[$0.opcode.x].load($0.opcode.byte)
							$0.pc.increment()
						},
			
			0x7 : { $0.register[$0.opcode.x] += $0.opcode.byte
							$0.pc.increment()
						},
			
			0x8: { try [
								0x0 : { $0.register[$0.opcode.x]  = $0.register[$0.opcode.y] },
								0x1 : { $0.register[$0.opcode.x] |= $0.register[$0.opcode.y] },
								0x2 : { $0.register[$0.opcode.x] &= $0.register[$0.opcode.y] },
								0x3 : { $0.register[$0.opcode.x] ^= $0.register[$0.opcode.y] },
								
								0x4 : { $0.register[$0.opcode.x] += $0.register[$0.opcode.y]
												$0.register[0xf        ].load($0.register[$0.opcode.x].overflow)
								},
								0x5 : { $0.register[$0.opcode.x] -= $0.register[$0.opcode.y]
												$0.register[0xf        ].load($0.register[$0.opcode.x].overflow)
								},
								0x6 : { $0.register[0xf        ].load($0.register[$0.opcode.x].bits[7])
												$0.register[$0.opcode.x].load($0.register[$0.opcode.x] >> 1)
								},
								0x7 : { $0.register[$0.opcode.y] -= $0.register[$0.opcode.x]
												$0.register[0xf        ].load($0.register[$0.opcode.y].overflow)
								},
								0xe : { $0.register[0xf        ].load($0.register[$0.opcode.x].bits[0])
												$0.register[$0.opcode.x].load($0.register[$0.opcode.x] << 1)
								}
				
							][$0.opcode.nibble, default: { _ in throw EmulationError.badInstruction }]($0)
							$0.pc.increment()
						},
			
			0x9 : { $0.pc.skip( $0.register[$0.opcode.x] != $0.register[$0.opcode.y] )},
			
			0xa : { $0.memoryindex.load( $0.opcode.address)
							$0.pc.increment()
						},
			
			0xb : { try $0.pc.jmp ( $0.opcode.address + $0.register[0] ) },
			

			0xd: {	$0.register[0xf].load(0)
							$0.register[0xf].load( $0.rendersprite (
								pixels: $0.memory[$0.memoryindex..<$0.memoryindex + $0.opcode.nibble],
								height: $0.opcode.nibble,
								x     : $0.register[$0.opcode.x],
								y     : $0.register[$0.opcode.y]
							))
							$0.pc.increment()
					 },
			
			0xe : { try [
								0x9e: { $0.pc.skip( $0.key[ $0.register[$0.opcode.x] ] == true  )},
								0xa1: { $0.pc.skip( $0.key[ $0.register[$0.opcode.x] ] == false )}
				
							][$0.opcode.byte, default: { _ in throw EmulationError.badInstruction }]($0)
						},

			0xf : { try [
								0x07: { $0.register[$0.opcode.x].load( $0.delaytimer ) },
								0x0a: { $0.waitkey($0.opcode.x)},
								0x15: { $0.delaytimer.load ( $0.register[$0.opcode.x] )},
								0x18: { $0.soundtimer.load ( $0.register[$0.opcode.x] )},
								0x1e: { $0.memoryindex.add ( $0.register[$0.opcode.x] )},
								0x29: { $0.memoryindex.load( $0.register[$0.opcode.x] * 5)},
								0x33: { $0.memory.load     ( $0.bcd($0.register[$0.opcode.x]), $0.memoryindex ) },
								
								0x55: {
									for idx in 0...$0.opcode.x {
										$0.memory.load($0.memoryindex + idx, $0.register[idx])
									}
								},
								
								0x65: {
									for idx in 0...$0.opcode.x {
										$0.register[idx].load( $0.memory[$0.memoryindex + idx] )
									}
								}
				
							][$0.opcode.byte, default: { _ in throw EmulationError.badInstruction }]($0)
							$0.pc.increment()
						}
	]

}

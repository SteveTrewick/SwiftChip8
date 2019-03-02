# SwiftChip8
A (fairly shonky) implementation of the CHIP 8 spec in Swift

A Swift version of [CHIP 8](https://en.wikipedia.org/wiki/CHIP-8), a virtual machine for an 8 bit computer. CHIP 8 was originally used in a COSMACS VIP computer in 1977 and then a bit later in graphing calculators.

These days it is the goto starter project for people interested in CPU emulation because it's relatively easy (compared to say, a Z80) and there are a bunch of reference implementations knocking about.

Like most versions, this one is incomplete, it lacks sound and the 'wait for a key press' function.

At the moment, it just loads the trip8 demo ROM from the bundle and executes that.

# TO DO

- Sound
- Wait key
- ROM loading UI

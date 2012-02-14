package imagelib.gif

import whiley.lang.*

define Reader as {
    int index,  // index of current byte in data
    int end,    // current end of block
    int boff,    // bit offset in current byte
    [byte] data 
}

public Reader Reader([byte] data, int start):
    end = Byte.toUnsignedInt(data[start])
    return {
        index: start+1,
        end: end,
        boff: 0,
        data: data
    }

public (bool,Reader) read(Reader reader):
    boff = reader.boff
    // first, read the current bit
    b = reader.data[reader.index]
    b = b >> boff
    b = b & 00000001b
    // now, move position to next bit
    boff = boff + 1
    if boff == 8:
        reader.boff = 0
        reader.index = reader.index + 1
        // FIXME ROLL OVER TO NEXT BLOCK
    else:
        reader.boff = boff
    // return the bit we've read
    return b == 00000001b,reader

public (byte,Reader) read(Reader reader, int nbits) requires nbits >= 0 && nbits < 8:
    mask = 00000001b
    r = 0b
    for i in 0..nbits:
        bit,reader = read(reader)
        if bit:
            r = r | mask
        mask = mask << 1
    return r,reader

public (int,Reader) readUnsignedInt(Reader reader, int nbits):
    base = 1
    r = 0
    for i in 0..nbits:
        bit,reader = read(reader)
        if bit:
            r = r + base
        base = base * 2
    return r,reader

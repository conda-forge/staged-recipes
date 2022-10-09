from PyByteBuffer import ByteBuffer

buf = ByteBuffer.allocate(50)
# write byte 0x10 and increment position by 1
buf.put(0x10)
buf.put([0xcc, 0xdd, 0xee])
buf.put('something')
buf.put(bytes([00] * 4))

# read 1 byte and increment position by 1
value = buf.get(1)
# read 10 bytes little endian and increment position by 10
value = buf.get(10, 'little')

# other allocations
buf = ByteBuffer.from_hex('deadbeef')
buf = ByteBuffer.wrap(bytes())

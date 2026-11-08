# patch.py
#Constructs gdb_index section.
import struct,sys,shutil
src,dst,secoff,mode=sys.argv[1],sys.argv[2],int(sys.argv[3],16),sys.argv[4]
b=bytearray(open(src,'rb').read())
ver,cuo,tuo,addro,symo,cpo=struct.unpack_from('<6I',b,secoff)
print('version',ver,'symtab',hex(symo),'pool',hex(cpo))
for i in range((cpo-symo)//8):
    so,cvo=struct.unpack_from('<II',b,secoff+symo+8*i)
    if so or cvo:
        name=b[secoff+cpo+so:b.index(0,secoff+cpo+so)].decode()
        print('slot',i,name,'cuvec',hex(cvo))
        if mode=='cuvec':
            # base = pool + off wraps to 16 bytes before the section on a 32-bit host
            new=(2**32-cpo-int(sys.argv[5],16) if len(sys.argv)>5 else 2**32-cpo-16)&0xffffffff
            struct.pack_into('<I',b,secoff+symo+8*i+4,new)
            print('patched cuvec ->',hex(new))
        break
open(dst,'wb').write(b)

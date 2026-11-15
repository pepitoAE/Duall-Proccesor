import re,sys
src,out=sys.argv[1],sys.argv[2]
L=[l.split('#')[0].strip() for l in open(src)]
L=[l for l in L if l and not l.startswith('.')]
lab={};ins=[]
for l in L:
    while ':' in l:
        a,l=l.split(':',1);lab[a.strip()]=len(ins)*4;l=l.strip()
    if l: ins.append(l)
def r(t):return int(t.strip()[1:])
def enc(s,pc):
    op,a=s.split(None,1);a=[x.strip() for x in a.split(',')]
    R=lambda f7,f3,rd,rs1,rs2:(f7<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|0x33
    if op=='add':return R(0,0,r(a[0]),r(a[1]),r(a[2]))
    if op=='sub':return R(0x20,0,r(a[0]),r(a[1]),r(a[2]))
    if op=='slt':return R(0,2,r(a[0]),r(a[1]),r(a[2]))
    if op=='addi':i=int(a[2])&0xfff;return (i<<20)|(r(a[1])<<15)|(r(a[0])<<7)|0x13
    if op in('lw','sw'):
        o,b=re.match(r'(-?\d+)\((x\d+)\)',a[1]).groups();o=int(o)&0xfff
        if op=='lw':return (o<<20)|(r(b)<<15)|(2<<12)|(r(a[0])<<7)|0x03
        return ((o>>5)<<25)|(r(a[0])<<20)|(r(b)<<15)|(2<<12)|((o&31)<<7)|0x23
    if op=='beq':
        o=(lab[a[2]]-pc)&0x1fff
        return (((o>>12)&1)<<31)|(((o>>5)&63)<<25)|(r(a[1])<<20)|(r(a[0])<<15)|(((o>>1)&15)<<8)|(((o>>11)&1)<<7)|0x63
    if op=='jal':
        o=(lab[a[1]]-pc)&0x1fffff
        return (((o>>20)&1)<<31)|(((o>>1)&0x3ff)<<21)|(((o>>11)&1)<<20)|(((o>>12)&0xff)<<12)|(r(a[0])<<7)|0x6f
    raise Exception(s)
with open(out,'w') as f:
    for i,s in enumerate(ins):f.write('%08x\n'%enc(s,i*4))
for k,v in lab.items():print(k,v)

import re,sys
L=[l.split('#')[0].strip() for l in open(sys.argv[1])]
L=[l for l in L if l and not l.startswith('.')]
lab={};ins=[]
for l in L:
    if l.endswith(':'): lab[l[:-1]]=len(ins)
    else: ins.append(l)
print("static instrs",len(ins),"fin at",lab['fin'])
R=[0]*32;M={};pc=0;n=0;tk=0;br=0;lu=0;prev=None
def r(t):return int(t[1:])
while pc!=lab['fin']:
    s=ins[pc];op,a=s.split(None,1);a=[x.strip() for x in a.split(',')];n+=1;npc=pc+1
    def mem(x):
        o,b=re.match(r'(-?\d+)\((x\d+)\)',x).groups();return int(o)+R[r(b)]
    if op=='addi':R[r(a[0])]=R[r(a[1])]+int(a[2])
    elif op=='add':R[r(a[0])]=R[r(a[1])]+R[r(a[2])]
    elif op=='sub':R[r(a[0])]=R[r(a[1])]-R[r(a[2])]
    elif op=='slt':R[r(a[0])]=int(R[r(a[1])]<R[r(a[2])])
    elif op=='lw':R[r(a[0])]=M.get(mem(a[1]),0)
    elif op=='sw':M[mem(a[1])]=R[r(a[0])]
    elif op=='beq':
        br+=1
        if R[r(a[0])]==R[r(a[1])]:npc=lab[a[2]];tk+=1
    elif op=='jal':npc=lab[a[1]];tk+=1;br+=1
    R[0]=0;pc=npc
print("dyn",n,"ctl",br,"taken",tk)
print({i:R[i] for i in range(32) if R[i]})
print({k-1536:v for k,v in sorted(M.items())})

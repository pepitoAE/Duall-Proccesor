import random,subprocess,sys,os

R=list(range(1,13))
def gen(rng):
    L=[];lab=0
    def body(n,depth):
        nonlocal lab
        out=[]
        i=0
        while i<n:
            k=rng.random()
            a,b,c=rng.choice(R),rng.choice(R+[0]),rng.choice(R+[0])
            if k<0.25: out.append(f"addi x{a}, x{b}, {rng.randint(-20,20)}")
            elif k<0.40: out.append(f"add x{a}, x{b}, x{c}")
            elif k<0.50: out.append(f"sub x{a}, x{b}, x{c}")
            elif k<0.58: out.append(f"slt x{a}, x{b}, x{c}")
            elif k<0.68: out.append(f"lw x{a}, {4*rng.randint(0,15)}(x0)")
            elif k<0.78: out.append(f"sw x{b}, {4*rng.randint(0,15)}(x0)")
            elif k<0.88:
                lab+=1;t=f"L{lab}";m=rng.randint(0,3)
                out.append(f"beq x{b}, x{c}, {t}");out+=body(m,depth);out.append(f"{t}:")
            elif k<0.92:
                lab+=1;t=f"L{lab}"
                out.append(f"jal x0, {t}");out+=body(rng.randint(0,2),depth);out.append(f"{t}:")
            elif depth<2:
                lab+=1;cr=20+depth;t=f"L{lab}";e=f"E{lab}"
                out.append(f"addi x{cr}, x0, {rng.randint(1,6)}");out.append(f"{t}:")
                out+=body(rng.randint(2,8),depth+1)
                if rng.random()<0.5:
                    out.append(f"addi x{cr}, x{cr}, -1");out.append(f"beq x{cr}, x0, {e}");out.append(f"jal x0, {t}");out.append(f"{e}:")
                else:
                    out.append(f"addi x{cr}, x{cr}, -1");out.append(f"slt x25, x0, x{cr}");out.append(f"addi x26, x0, 1");out.append(f"beq x25, x26, {t}")
            i+=1
        return out
    L=body(rng.randint(10,40),0)
    L+=["fin:","jal x0, fin"]
    return L
def model(L):
    import re
    lab={};ins=[]
    for l in L:
        if l.endswith(':'):lab[l[:-1]]=len(ins)
        else: ins.append(l)
    if len(ins)>250: return None,None
    Rg=[0]*32;M=[0]*16;pc=0;n=0
    r=lambda t:int(t[1:])
    while pc!=lab['fin']:
        n+=1
        if n>3000: return None,None
        op,a=ins[pc].split(None,1);a=[x.strip() for x in a.split(',')];npc=pc+1
        S=lambda v:((v+2**31)%2**32)-2**31
        if op=='addi':Rg[r(a[0])]=S(Rg[r(a[1])]+int(a[2]))
        elif op=='add':Rg[r(a[0])]=S(Rg[r(a[1])]+Rg[r(a[2])])
        elif op=='sub':Rg[r(a[0])]=S(Rg[r(a[1])]-Rg[r(a[2])])
        elif op=='slt':Rg[r(a[0])]=int(Rg[r(a[1])]<Rg[r(a[2])])
        elif op=='lw':o=int(a[1].split('(')[0]);Rg[r(a[0])]=M[o//4]
        elif op=='sw':o=int(a[1].split('(')[0]);M[o//4]=Rg[r(a[0])]
        elif op=='beq':
            if Rg[r(a[0])]==Rg[r(a[1])]:npc=lab[a[2]]
        elif op=='jal':npc=lab[a[1]]
        Rg[0]=0;pc=npc
    return [x%2**32 for x in Rg[1:]]+[x%2**32 for x in M],n
vers=sys.argv[2:];N=int(sys.argv[1]);bad=0;tot=0
for seed in range(N):
    rng=random.Random(seed);L=gen(rng);exp,n=model(L)
    if exp is None: continue
    tot+=1
    open('p.s','w').write('\n'.join(L)+'\n')
    subprocess.run(['python3','../asm.py','p.s','rand.mem'],capture_output=True)
    for v in vers:
        subprocess.run(['vvp','-n',f'{v}.vvp'],capture_output=True)
        got=[int(x)%2**32 for x in open('out.txt').read().split()]
        if got!=exp:
            bad+=1;print("MISMATCH seed",seed,v);os.system(f"cp p.s fail_{seed}.s")
print("programas",tot,"fallos",bad)

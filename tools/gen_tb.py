import re,sys
src,tbname,memname,base_addr,nwords=sys.argv[1],sys.argv[2],sys.argv[3],int(sys.argv[4]),int(sys.argv[5])
L=[l.split('#')[0].strip() for l in open(src)]
L=[l for l in L if l]
lab={};ins=[]
for l in L:
    if l.endswith(':'):lab[l[:-1]]=len(ins)
    else: ins.append(l)
stages=[k for k in lab if k.startswith('etapa_')]+['fin']
starts=[lab[k] for k in stages]
chk=[ (starts[i+1]-1)*4 for i in range(len(stages)-1)]
R=[0]*32;M={};pc=0;snaps=[];n=0;taken=0;br=0
r=lambda t:int(t[1:])
S=lambda v:((v+2**31)%2**32)-2**31
while pc!=lab['fin']:
    op,a=ins[pc].split(None,1);a=[x.strip() for x in a.split(',')];npc=pc+1;n+=1
    def mem(x):
        o,b=re.match(r'(-?\d+)\((x\d+)\)',x).groups();return int(o)+R[r(b)]
    if op=='addi':R[r(a[0])]=S(R[r(a[1])]+int(a[2]))
    elif op=='add':R[r(a[0])]=S(R[r(a[1])]+R[r(a[2])])
    elif op=='sub':R[r(a[0])]=S(R[r(a[1])]-R[r(a[2])])
    elif op=='slt':R[r(a[0])]=int(R[r(a[1])]<R[r(a[2])])
    elif op=='lw':R[r(a[0])]=M.get(mem(a[1]),0)
    elif op=='sw':M[mem(a[1])]=R[r(a[0])]
    elif op=='beq':
        br+=1
        if R[r(a[0])]==R[r(a[1])]:npc=lab[a[2]];taken+=1
    elif op=='jal':npc=lab[a[1]];taken+=1;br+=1
    R[0]=0
    if pc*4 in chk: snaps.append((list(R),[M.get(base_addr+4*k,0) for k in range(nwords)]))
    pc=npc
assert len(snaps)==len(chk)
print(f"// dinamicas={n} saltos={br} tomados={taken} estaticas={len(ins)}",file=sys.stderr)
for i,(rr,mm) in enumerate(snaps):
    print(f"// etapa {i+1}: "+", ".join(f"x{k}={rr[k]}" for k in range(1,32) if rr[k]),file=sys.stderr)
    print(f"//   mem: "+", ".join(f"M[{base_addr+4*k}]={mm[k]}" for k in range(nwords) if mm[k]),file=sys.stderr)
ns=len(chk)
t=open(sys.argv[6] if len(sys.argv)>6 else 'A_single_issue/sim/tb_prog_profesor.v').read()
t=t.replace("tb_prog_profesor",tbname).replace('"prog_profesor.mem"',f'"{memname}"')
t=re.sub(r"  localparam PC_A.*?localparam BASE   = 384;\n",
  "".join(f"  localparam PC_{i} = 32'd{c};\n" for i,c in enumerate(chk))+f"  localparam PC_FIN = 32'd{lab['fin']*4};\n  localparam BASE   = {base_addr//4};\n  localparam NW     = {nwords};\n  localparam NS     = {ns};\n",t,flags=re.S)
t=t.replace("reg chk_A, chk_B, chk_C, chk_D;\n  reg ok_A, ok_B, ok_C, ok_D;","reg [NS-1:0] chk;\n  reg [NS-1:0] ok;")
t=t.replace("reg [31:0] exp_r [0:3][0:31];\n  reg [31:0] exp_m [0:3][0:13];\n  integer    n_m [0:3];","reg [31:0] exp_r [0:NS-1][0:31];\n  reg [31:0] exp_m [0:NS-1][0:NW-1];")
body="  task cargar_esperados;\n    integer s, r;\n    begin\n      for (s = 0; s < NS; s = s + 1) begin\n        for (r = 0; r < 32; r = r + 1) exp_r[s][r] = 0;\n        for (r = 0; r < NW; r = r + 1) exp_m[s][r] = 0;\n      end\n"
for i,(rr,mm) in enumerate(snaps):
    body+="".join(f"      exp_r[{i}][{k}] = {rr[k]%2**32};\n" for k in range(1,32) if rr[k])
    body+="".join(f"      exp_m[{i}][{k}] = {mm[k]%2**32};\n" for k in range(nwords) if mm[k])
body+="    end\n  endtask\n"
t=re.sub(r"  task cargar_esperados;.*?endtask\n",body,t,flags=re.S)
t=t.replace("for (r = 0; r < 14; r = r + 1)","for (r = 0; r < NW; r = r + 1)")
t=t.replace('$display("  [ETAPA %c] x%0d = %0d, esperado %0d", "A"+s,','$display("  [ETAPA %0d] x%0d = %0d, esperado %0d", s+1,')
t=t.replace('$display("  [ETAPA %c] M[x1+%0d] = %0d, esperado %0d", "A"+s, 4*r,','$display("  [ETAPA %0d] M[%0d] = %0d, esperado %0d", s+1, 4*(BASE+r),')
t=t.replace('$display("Etapa %c  ciclo %0d  retiradas %0d  -> %s", "A"+s,','$display("Etapa %0d  ciclo %0d  retiradas %0d  -> %s", s+1,')
t=re.sub(r"      case \(s\).*?endcase\n","      chk[s] = 1;\n      ok[s]  = (e == 0);\n",t,flags=re.S)
t=re.sub(r"        if \(pc == PC_A\) comprobar\(0\);\n.*?        if \(pc == PC_D\) begin\n          comprobar\(3\);",
  "".join(f"        if (pc == PC_{i}) comprobar({i});\n" for i in range(ns-1))+f"        if (pc == PC_{ns-1}) begin\n          comprobar({ns-1});",t,flags=re.S)
t=t.replace("chk_A = 0; chk_B = 0; chk_C = 0; chk_D = 0;\n    ok_A = 0; ok_B = 0; ok_C = 0; ok_D = 0;","chk = 0;\n    ok  = 0;")
t=t.replace("    chk_A = 0; chk_B = 0; chk_C = 0; chk_D = 0;\n","    chk = 0;\n")
t=re.sub(r"  wire \[31:0\] x25 = .*?\n(  wire \[31:0\] x\d+ = .*?\n)*","",t)
open(f"{tbname}.v","w").write(t)

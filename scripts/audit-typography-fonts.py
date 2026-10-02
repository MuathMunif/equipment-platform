# Read-only audit of sfnt metadata and Unicode cmap; no external dependencies.
from pathlib import Path
import struct,json,hashlib
U=lambda b,o:struct.unpack_from('>H',b,o)[0]
L=lambda b,o:struct.unpack_from('>I',b,o)[0]
I=lambda b,o:struct.unpack_from('>i',b,o)[0]

def audit(p):
 b=p.read_bytes();tables={}
 for i in range(U(b,4)):
  q=12+i*16;tag=b[q:q+4].decode();off=L(b,q+8);tables[tag]=b[off:off+L(b,q+12)]
 c=tables['cmap']; points=set()
 for i in range(U(c,2)):
  q=4+i*8;platform,encoding=U(c,q),U(c,q+2);o=L(c,q+4);fmt=U(c,o)
  if platform not in [0,3]:continue
  if fmt==12:
   for j in range(L(c,o+12)):
    z=o+16+12*j;start,end,glyph=L(c,z),L(c,z+4),L(c,z+8)
    points.update(range(start+(glyph==0),end+1))
  elif fmt==4:
   n=U(c,o+6)//2;ends=o+14;starts=ends+2*n+2;deltas=starts+2*n;offsets=deltas+2*n
   for j in range(n):
    for cp in range(U(c,starts+j*2),U(c,ends+j*2)+1):
     delta=U(c,deltas+j*2);ro=U(c,offsets+j*2)
     glyph=(cp+delta)%65536 if ro==0 else U(c,offsets+j*2+ro+2*(cp-U(c,starts+j*2)))
     if ro and glyph:glyph=(glyph+delta)%65536
     if glyph and cp!=65535:points.add(cp)
 axes=[]
 if 'fvar' in tables:
  f=tables['fvar'];start,size=U(f,4),U(f,10)
  for i in range(U(f,8)):
   q=start+i*size;axes.append([f[q:q+4].decode(),*[I(f,q+k)/65536 for k in [4,8,12]]])
 samples={'urdu':'ٹڈڑںھہےپچژگ','arabic_marks':'بِسْمِ اللَّهِ','latin_digits':'Volvo FH EQ-004 0123456789.−-','arabic_digits':'٠١٢٣٤٥٦٧٨٩'}
 return {'file':str(p),'weight':U(tables['OS/2'],4),'axes':axes,'shaping_tables':[x for x in ['GSUB','GPOS','GDEF'] if x in tables],'missing':{k:''.join(sorted(set(ch for ch in v if ord(ch) not in points))) for k,v in samples.items()},'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)}
rows=[audit(p) for d in ['app/assets/design_fonts','app/assets/typography_fonts'] for p in sorted(Path(d).glob('*.ttf'))]
print(json.dumps(rows,ensure_ascii=False,indent=2))

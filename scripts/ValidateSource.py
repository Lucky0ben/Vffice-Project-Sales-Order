from pathlib import Path
import json,re,sys
root=Path(__file__).resolve().parents[1]
errors=[]
seen={}
for project in ['app','tests']:
    manifest=json.loads((root/project/'app.json').read_text())
    ranges=manifest['idRanges']
    for f in (root/project/'src').glob('*.al'):
        s=f.read_text()
        m=re.match(r'(\w+) (\d+) "([^"]+)"',s)
        if not m:errors.append(str(f)+': missing object declaration');continue
        typ,num,name=m[1],int(m[2]),m[3]
        if (typ,num) in seen:errors.append('Duplicate '+str((typ,num)))
        seen[typ,num]=f
        if len(name)>30:errors.append('Object name exceeds 30: '+name)
        if not any(r['from']<=num<=r['to'] for r in ranges):errors.append('Object out of range: '+name)
        if s.count('{')!=s.count('}'):errors.append('Brace mismatch: '+name)
        if 'TODO' in s or 'NotImplemented' in s:errors.append('Unimplemented placeholder: '+name)
for p in root.rglob('*.json'):json.loads(p.read_text())
if (root/'app/tests').exists():errors.append('Test source nested in application')
print('Checked',len(seen),'AL object declarations and JSON manifests.')
print('This is static structural validation, not an AL compilation or sandbox test.')
if errors:
    print('\n'.join(errors));sys.exit(1)
print('PASS')

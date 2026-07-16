import codecs
def resolve_file(filepath, resolve_type='both'):
    with codecs.open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
    
    out = []
    in_head = False
    in_theirs = False
    
    for line in lines:
        if line.startswith('<<<<<<<'):
            in_head = True
            continue
        elif line.startswith('======='):
            in_head = False
            in_theirs = True
            continue
        elif line.startswith('>>>>>>>'):
            in_theirs = False
            continue
            
        if in_head and resolve_type == 'theirs':
            continue
        if in_theirs and resolve_type == 'ours':
            continue
            
        out.append(line)
        
    with open(filepath, 'w') as f:
        f.writelines(out)

resolve_file('backend/app/main.py', 'both')
resolve_file('frontend/pubspec.yaml', 'both')
resolve_file('backend/app/firebase_config.py', 'theirs')
resolve_file('frontend/lib/main.dart', 'both')

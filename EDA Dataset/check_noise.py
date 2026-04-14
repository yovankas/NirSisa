import csv, re
from collections import Counter

noise = Counter()
samples = {}

with open('Indonesian_Food_Recipes_Cleaned_v2.csv', encoding='utf-8') as f:
    for i, row in enumerate(csv.DictReader(f)):
        for ing in [x.strip() for x in row.get('Ingredients Cleaned','').split(', ') if x.strip()]:
            if ':' in ing: noise['colon'] += 1
            if ';' in ing: noise['semicolon'] += 1
            if ',' in ing: noise['inner_comma'] += 1
            if len(ing) > 40: noise['long>40'] += 1
            if re.search(r'\d', ing): noise['has_digits'] += 1
            if re.search(r'\b[mndgpqx]\b', ing):
                noise['single_letter'] += 1
                if 'single_letter' not in samples: samples['single_letter'] = f'{i}: {ing}'
            for a in ['sckpnya','lmbr','btng','ptng','ekr','yg ','sdh','bwg','russ','slera','kya','saos']:
                if a in ing:
                    k = f'abbr:{a.strip()}'
                    noise[k] += 1
                    if k not in samples: samples[k] = f'{i}: {ing}'
            for d in ['bersih','matang','korek api','dibuang','empuk','lembut','wangi','enak','mentah','potong2','kecil2','tipis2','sobek2']:
                if d in ing:
                    k = f'desc:{d}'
                    noise[k] += 1
                    if k not in samples: samples[k] = f'{i}: {ing}'

for k, v in noise.most_common(25):
    s = samples.get(k, '')
    print(f'{k:25s}: {v:6d}  {s}')

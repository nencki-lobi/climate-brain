# Import dependencies
import os
import glob as gl
import pandas as pd
import re


def custom2df(customfile):
    fname = os.path.basename(customfile)
    subject = fname.split('-')[0]
    data = pd.read_csv(customfile, sep='\t', header=None, names=['trial', 'response'])
    out = data
    out.insert(0, "code", subject)
    return out


def trial2money(code):
    pat = re.findall(r'm\d|dl|dr', code)
    c2m = dict(dl=0, dr=0, m0=0, m1=10, m2=50, m3=80, m4=100, m5=120)
    return c2m[pat[0]]


def trial2carbon(code):
    pat = re.findall(r'c\d|dl|dr', code)
    c2c = dict(dl=0, dr=0, c0=0, c1=2, c2=10, c3=25, c4=40, c5=50)
    return c2c[pat[0]]


ngr = pd.read_csv('../../data/questionnaires/subjects.csv')
subjects = ngr["code"].str.replace('ngr', '')

dfl = []
for i, sub in enumerate(subjects):
    custom = gl.glob('../../data/logs/' + sub + '*cet*custom.txt')[0]
    df = custom2df(custom)
    dfl.append(df)
final = pd.concat(dfl)

final["money"] = final["trial"].apply(lambda x: trial2money(x))
final["carbon"] = final["trial"].apply(lambda x: trial2carbon(x))

final.to_csv('../../output/cet-trials-by-subject.csv', index=False)

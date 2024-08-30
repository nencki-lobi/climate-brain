# Import dependencies

import os
import glob as gl
import pandas as pd
import numpy as np
import re

# Set paths

workdir = os.environ['HOME']
bidsdir = os.path.join(workdir, 'ds-ngr/bids')

# Define functions


def log2df(logfile, customfile):

    fname = os.path.basename(logfile)
    prefix = fname.split('-')[0]

    # Read logfile
    ldata = pd.read_csv(logfile,
                        sep='\t',
                        header=None, skiprows=[0, 1, 2, 3],
                        usecols=[0, 2, 3, 4], names=['participant_id', 'event', 'trial_code', 'time'],
                        skipfooter=16, engine='python')

    # Extra cleaning steps to handle special cases (fail messages, quit events)
    ldata = (ldata
             .query('participant_id == @prefix')
             .dropna()
             )

    # Read customfile
    cdata = pd.read_csv(customfile, sep='\t', header=None, names=['trial_code', 'response'])

    # Merge data from both sources
    data = pd.merge(ldata, cdata, on="trial_code", how="left")

    # Assign type
    data['trial_type'] = np.select(
        [data['trial_code'].str.match("^[mc]"),
         data['trial_code'].str.match("^d")],
        ["CET",
         "dummy"],
        default=np.nan)

    # Set onset
    first_pulse = data.query('event == "Pulse"').iloc[0]
    data['onset'] = (data['time'] - first_pulse['time']) / 10000

    # Set duration
    data = data.query('event != "Pulse"').reset_index(drop=True)
    data['duration'] = 10
    data['RT'] = np.select(
        [data['response'].isin(['LEFT', 'RIGHT']),
         data['response'] == 'NONE'],
        [-data['onset'].diff(periods=-1),
         10],
        default=np.nan)

    # Retrive money & carbon values
    data["money"] = data["trial_code"].apply(lambda x: trial2money(x))
    data["carbon"] = data["trial_code"].apply(lambda x: trial2carbon(x))

    # Prepare output
    out = (data
           .query('trial_code.str.match("^[mcd]")')
           .get(['participant_id', 'onset', 'duration', 'trial_type', 'trial_code', 'response', 'RT', 'money', 'carbon'])
           )

    return out


def trial2money(code):
    pat = re.findall(r'm\d|dl|dr', code)
    c2m = dict(dl=0, dr=0, m0=0, m1=10, m2=50, m3=80, m4=100, m5=120)
    out = c2m[pat[0]] if pat else -1
    return out


def trial2carbon(code):
    pat = re.findall(r'c\d|dl|dr', code)
    c2c = dict(dl=0, dr=0, c0=0, c1=2, c2=10, c3=25, c4=40, c5=50)
    out = c2c[pat[0]] if pat else -1
    return out


ngr = pd.read_csv('../../data/questionnaires/subjects.csv')
subjects = ngr["code"].str.replace('ngr', '')

dfl = []
for i, sub in enumerate(subjects):
    subdir = 'sub-' + sub
    os.makedirs(os.path.join(bidsdir, subdir), exist_ok=True)
    log = gl.glob('../../data/logs/' + sub + '*cet*.log')[0]
    custom = gl.glob('../../data/logs/' + sub + '*cet*custom.txt')[0]
    df = log2df(log, custom)
    dfl.append(df)
    (df.drop(columns=['participant_id'])
     .to_csv(os.path.join(bidsdir, subdir, 'sub-' + sub + '_task-cet_events.tsv'), sep='\t', index=False))
final = pd.concat(dfl)

final.to_csv('../../output/cet-events.tsv', sep='\t', index=False)

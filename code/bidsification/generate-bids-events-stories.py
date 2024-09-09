# Import dependencies

import os
import glob as gl
import pandas as pd
import numpy as np

# Set paths

workdir = os.environ['HOME']
bidsdir = os.path.join(workdir, 'bids-wannabe') # location of a dataset we want to bidsify

# Define functions


def log2df(logfile, run):

    fname = os.path.basename(logfile)
    prefix = fname.split('-')[0]

    # Read logfile
    data = pd.read_csv(logfile,
                       sep='\t',
                       header=None, skiprows=[0, 1, 2, 3],
                       usecols=[0, 2, 3, 4], names=['participant_id', 'event', 'trial_code', 'time'],
                       skipfooter=16, engine='python')

    data.insert(1, "run", run)

    # Extra cleaning steps to handle special cases (fail messages, quit events)
    data = (data
            .query('participant_id == @prefix')
            .dropna()
            )

    # Find events
    isstory = data['trial_code'].str.contains("ANG|HOP|NEU")
    isquestion = data['trial_code'] == "Valence"
    isval = data['trial_code'].str.contains("Valence Response")
    isaro = data['trial_code'].str.contains("Arousal Response")

    # Assign code
    trial_codes = data[isstory]['trial_code'].values
    data.loc[isquestion, 'trial_code'] = 'Q_' + trial_codes

    # Assign type
    data['trial_type'] = np.select(
        [isstory, isquestion],
        [data["trial_code"].apply(lambda x: code2type(x)), "Q"],
        default=np.nan)

    # Set onset
    first_pulse = data.query('event == "Pulse"').iloc[0]
    data['onset'] = (data['time'] - first_pulse['time'])/10000

    # Set duration
    data['duration'] = np.select(
        [isstory, isquestion],
        [15, 11])

    # Retrieve valence & arousal ratings
    valence = (data[isval]['trial_code']
               .squeeze()
               .str.split(': ').str[1]
               .values)

    arousal = (data[isaro]['trial_code']
               .squeeze()
               .str.split(': ').str[1]
               .values)

    data.loc[isstory, 'valence'] = valence
    data.loc[isquestion, 'valence'] = valence

    data.loc[isstory, 'arousal'] = arousal
    data.loc[isquestion, 'arousal'] = arousal

    # Prepare output
    out = (data[isstory | isquestion]
           .get(['participant_id', 'run', 'onset', 'duration', 'trial_type', 'trial_code', 'valence', 'arousal'])
           .sort_index())

    return out


def code2type(trial_code):
    anger = ['ANG8', 'ANG20', 'ANG17', 'ANG30', 'ANG25', 'ANG6', 'ANG9', 'ANG1', 'ANG12', 'ANG3', 'ANG21', 'ANG7']
    hope = ['HOP23', 'HOP15', 'HOP27', 'HOP13', 'HOP17', 'HOP26', 'HOP5', 'HOP11', 'HOP19', 'HOP7', 'HOP22', 'HOP16']
    neutral = ['NEU14', 'NEU30', 'NEU9', 'NEU15', 'NEU1', 'NEU21', 'NEU29', 'NEU23', 'NEU6', 'NEU12', 'NEU24', 'NEU11']
    control = ['NEU26', 'NEU16', 'NEU4', 'NEU25', 'NEU3', 'NEU18', 'NEU10', 'NEU22', 'NEU17', 'NEU27', 'NEU2', 'NEU5']

    trial_type = ''

    if trial_code in anger:
        trial_type = 'ANG'
    elif trial_code in hope:
        trial_type = 'HOP'
    elif trial_code in neutral:
        trial_type = 'NEU'
    elif trial_code in control:
        trial_type = 'CON'
    return trial_type


ngr = pd.read_csv('../../data/questionnaires/subjects.csv')
subjects = ngr["code"].str.replace('ngr', '')

runs = ['R1', 'R2', 'R3']

dfl = []
for i, sub in enumerate(subjects):
    subdir = 'sub-' + sub
    os.makedirs(os.path.join(bidsdir, subdir, 'func'), exist_ok=True)
    for j, r in enumerate(runs):
        log = gl.glob('../../data/logs/' + sub + '*stories*' + r + '*.log')[0]
        df = log2df(log, r)
        dfl.append(df)
        (df.drop(columns=['participant_id', 'run'])
         .to_csv(os.path.join(bidsdir, subdir, 'func', 'sub-' + sub + '_task-stories_run-0' + str(j+1) + '_events.tsv'),
                 sep='\t', index=False))
final = pd.concat(dfl)

final.to_csv('../../output/stories-events.tsv', sep='\t', index=False)

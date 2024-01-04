# Import dependencies
import os
import glob as gl
import pandas as pd


def log2df(logfile):
    fname = os.path.basename(logfile)
    subject = fname.split('-')[0]
    data = pd.read_csv(logfile,
                       sep='\t',
                       header=None, skiprows=[0, 1, 2, 3],
                       usecols=[0, 3], names=['code', 'trial'],
                       skipfooter=16, engine='python')

    # Extra cleaning steps to handle special cases (fail messages, quit events)
    data = data[data['code'].str.contains(subject)]
    data = data.dropna()

    stories = data[data['trial'].str.contains('ANG|HOP|NEU')].reset_index(drop=True)
    responses = data[data['trial'].str.contains('Response')]

    val = (responses[responses['trial'].str.contains("Valence")]
           .replace(to_replace='Valence Response: ', value='', regex=True)
           .rename(columns={'trial': 'valence'})
           .reset_index(drop=True))
    aro = (responses[responses['trial'].str.contains("Arousal")]
           .replace(to_replace='Arousal Response: ', value='', regex=True)
           .rename(columns={'trial': 'arousal'})
           .reset_index(drop=True))

    out = pd.concat([stories, val["valence"], aro["arousal"]], axis=1)
    return out


def trial2category(code):
    anger = ['ANG8', 'ANG20', 'ANG17', 'ANG30', 'ANG25', 'ANG6', 'ANG9', 'ANG1', 'ANG12', 'ANG3', 'ANG21', 'ANG7']
    hope = ['HOP23', 'HOP15', 'HOP27', 'HOP13', 'HOP17', 'HOP26', 'HOP5', 'HOP11', 'HOP19', 'HOP7', 'HOP22', 'HOP16']
    neutral = ['NEU14', 'NEU30', 'NEU9', 'NEU15', 'NEU1', 'NEU21', 'NEU29', 'NEU23', 'NEU6', 'NEU12', 'NEU24', 'NEU11']
    control = ['NEU26', 'NEU16', 'NEU4', 'NEU25', 'NEU3', 'NEU18', 'NEU10', 'NEU22', 'NEU17', 'NEU27', 'NEU2', 'NEU5']

    category = ''

    if code in anger:
        category = 'ANG'
    elif code in hope:
        category = 'HOP'
    elif code in neutral:
        category = 'NEU'
    elif code in control:
        category = 'CON'
    return category


ngr = pd.read_csv('../../data/questionnaires/demo-by-subject.csv')
subjects = ngr["code"].str.replace('ngr', '')

runs = ['R1', 'R2', 'R3']

dfl = []
for i, sub in enumerate(subjects):
    for j, r in enumerate(runs):
        run = r
        log = gl.glob('../../data/logs/' + sub + '*stories*' + run + '*.log')[0]
        df = log2df(log)
        df.insert(1, "run", run)
        dfl.append(df)
final = pd.concat(dfl)

final["category"] = final["trial"].apply(lambda x: trial2category(x))
final.insert(2, 'category', final.pop('category'))

final.to_csv('../../output/stories-trials-by-subject.csv', index=False)

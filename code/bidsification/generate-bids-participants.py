# Import dependencies

import pandas as pd
import os

# Set paths

workdir = os.environ['HOME']
bidsdir = os.path.join(workdir, 'ds-ngr/bids')

# Load subjects

subjects = pd.read_csv('../../output/condition-by-subject.csv')

# Load demographic data

demo = pd.read_csv('../../data/questionnaires/demographic.csv',
                   dtype={'val': pd.Int64Dtype()})  # nullable integer
demo['code'] = demo['code'].str.replace('ngr', '')
demo.drop('sid', axis=1, inplace=True)

demo_dict = {0: 'sex', 2: 'age', 3: 'residence', 4: 'education',
             6: 'CCC', 7: 'actions', 8: 'lifestyle', 9: 'driver', 10: 'car',
             11: 'politics1', 12: 'politics2', 13: 'politics3', 14: 'SES'}

demo_transposed = demo.pivot(
    index='code',
    columns=['ord'],
    values='val'
).reset_index().rename(columns=demo_dict)

demo_transposed['age'] = 2023 - demo_transposed['age']

# Load questionnaire data

questionnaires = pd.read_csv('../../data/questionnaires/psychometric.csv')
questionnaires['code'] = questionnaires['code'].str.replace('ngr', '')
questionnaires.drop('sid', axis=1, inplace=True)

questionnaires_transposed = questionnaires.pivot(
    index='code',
    columns=['name', 'ord'],
    values='opt'
).reset_index()

# Caluculate questionnaire scores

questionnaires_transposed['PCAE_i'] = questionnaires_transposed[[('PCAE-pl', i) for i in [0, 1]]].sum(axis=1)
questionnaires_transposed['PCAE_c'] = questionnaires_transposed[[('PCAE-pl', i) for i in [2, 3]]].sum(axis=1)
questionnaires_transposed['PCAE'] = questionnaires_transposed['PCAE_i'] + questionnaires_transposed['PCAE_c']
questionnaires_transposed['PD'] = questionnaires_transposed[[('PD-pl', i) for i in [0, 1]]].sum(axis=1)
questionnaires_transposed['NR'] = questionnaires_transposed[[('NRm-pl', i) for i in [0, 1, 2, 3, 4, 5]]].sum(axis=1)
questionnaires_transposed['ICE_anger'] = questionnaires_transposed[[('ICE-32-pl', i) for i in [0, 1, 2, 3]]].sum(axis=1)
questionnaires_transposed['ICE_discontent'] = questionnaires_transposed[[('ICE-32-pl', i) for i in [4, 5, 6, 7]]].sum(axis=1)
questionnaires_transposed['ICE_enthusiasm'] = questionnaires_transposed[[('ICE-32-pl', i) for i in [8, 9, 11, 12]]].sum(axis=1)
questionnaires_transposed['ICE_powerlessness'] = questionnaires_transposed[[('ICE-32-pl', i) for i in [13, 14, 15, 16]]].sum(axis=1)
questionnaires_transposed['ICE_guilt'] = questionnaires_transposed[[('ICE-32-pl', i) for i in [17, 19, 20, 21]]].sum(axis=1)
questionnaires_transposed['ICE_isolation'] = questionnaires_transposed[[('ICE-32-pl', i) for i in [22, 24, 25, 26]]].sum(axis=1)
questionnaires_transposed['ICE_anxiety'] = questionnaires_transposed[[('ICE-32-pl', i) for i in [27, 28, 29, 30]]].sum(axis=1)
questionnaires_transposed['ICE_sorrow'] = questionnaires_transposed[[('ICE-32-pl', i) for i in [31, 32, 33, 34]]].sum(axis=1)

scores = questionnaires_transposed[['code', 'PCAE_i', 'PCAE_c', 'PCAE', 'PD', 'NR',
                                    'ICE_anger', 'ICE_discontent', 'ICE_enthusiasm', 'ICE_powerlessness',
                                    'ICE_guilt', 'ICE_isolation', 'ICE_anxiety', 'ICE_sorrow']]

scores.columns = [f'{col[0]}' for col in scores.columns]

# Prepare & save final output

dfs = [subjects, demo_transposed, scores]
dfs = [df.set_index('code') for df in dfs]
final = pd.concat(dfs, join='outer', axis=1)
final = final.add_prefix('sub-', axis=0)
final = final.reset_index(names=['participant_id'])

final.to_csv(os.path.join(bidsdir, 'participants.tsv'), na_rep='n/a', sep='\t', index=False)

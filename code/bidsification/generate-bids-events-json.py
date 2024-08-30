# Import dependencies

import json
import os

# Set paths

workdir = os.environ['HOME']
bidsdir = os.path.join(workdir, 'ds-ngr/bids')

# Define functions


def add_entry(data, key, description, levels_or_units):
    if levels_or_units is None:
        data[key] = {"Description": description}
    else:
        if isinstance(levels_or_units, dict):
            data[key] = {"Description": description, "Levels": levels_or_units}
        else:
            data[key] = {"Description": description, "Units": levels_or_units}


def make_json(entries, fpath):

    # Loop through the entries to generate the final output
    final = {}
    for key, description, levels_or_units in entries:
        add_entry(final, key, description, levels_or_units)

    # Save output as a nicely formatted JSON file
    with open(fpath, "w") as file:
        json.dump(final, file, indent=4)


# Prepare entries

entries_stories = [
    ("trial_type", "Trial type",
     {"ANG": "Presentation of a target anger story",
      "HOP": "Presentation of a target hope story",
      "NEU": "Presentation of a target neutral story",
      "CON": "Presentation of a control neutral story",
      "Q": "Presentation of rating scales"}),
    ("trial_code", "Trial code (unique identifier)", None),
    ("valence", "Valence rating associated with a trial",
     "Points on a scale, where: 0 - Negative emotions, 5 - No emotions, 10 - Positive emotions"),
    ("arousal", "Arousal rating associated with a trial",
     "Points on a scale, where: 0 - Low arousal, 10 - High arousal")
]

entries_cet = [
    ("trial_type", "Trial type",
     {"CET": "Presentation of a target decision",
      "dummy": "Presentation of a dummy decision"}),
    ("trial_code",
     "Trial code (unique identifier). "
     "In target trials, the trial code starts with `m` or `c`. "
     "If it starts with `m`, monetary reward was presented on the left and CO2 emission on the right of the screen. "
     "If if starts with `c`, CO2 emission was presented on the left and monetary reward on the right of the screen. "
     "In the dummy trials, the trial code starts with `dl` or `dr`. "
     "If it starts with `dl`, the participant was asked to select the option on the left of the screen. "
     "If it starts with `dr`, the participant was asked to select the option on the right of the screen.",
     None),
    ("response", "Response selected by the participant",
     {"LEFT": "Participant selected option on the left",
      "RIGHT": "Participant selected option on the right"}),
    ("RT", "Response time, as measured from the onset of the trial", "Seconds"),
    ("money", "Monetary reward that could be gained by the participant",
     "Polish zloty"),
    ("carbon", "Amount of CO2 emission that could be reduced by the participant",
     "Kilograms (kg)")
]

# Generate JSON files

make_json(entries_stories, os.path.join(bidsdir, 'task-stories_events.json'))
make_json(entries_cet, os.path.join(bidsdir, 'task-cet_events.json'))


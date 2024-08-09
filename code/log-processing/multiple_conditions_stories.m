function multiple_conditions_stories(events, run)
    
    %% Define events

    SEMO = events(matches(events.trial_type,["ANG","HOP","NEU"]), :);
    SCON = events(matches(events.trial_type,"CON"), :);
    questions = events(matches(events.trial_type,"Q"), :);
    
    %% Create multiple conditions structure

    names = {'SEMO', 'SCON', 'Q'};
    onsets = {SEMO.onset, SCON.onset, questions.onset};
    durations = {15, 15, 11};
    
    %% Save output

    outdir = './code/first-level/multiple-conditions-stories';

    if ~exist(outdir, 'dir')
       mkdir(outdir)
    end
    
    save(fullfile(outdir, ['multiple-conditions-stories-' run '.mat']), ...
        'names', 'onsets', 'durations');
    
    clearvars -except names onsets durations

end

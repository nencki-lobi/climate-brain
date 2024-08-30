function multiple_conditions_cet(events, subject, outdir)

    %% Define events
    
    CET = events(startsWith(events.trial_type, "CET") & ~matches(events.response, "NONE"), :);
    dummy = events(startsWith(events.trial_type, "dummy") & ~matches(events.response, "NONE"), :);
    miss = events(matches(events.response, "NONE"), :);
    
    %% Create multiple conditions structure

    if isempty(miss)
        names = {'CET', 'dummy', 'CET leftover', 'dummy leftover'};
        onsets = {
            CET.onset
            dummy.onset
            CET.onset + CET.RT
            dummy.onset + dummy.RT}';
        durations = {
            CET.RT
            dummy.RT
            CET.duration - CET.RT
            dummy.duration - dummy.RT}';
    else
        names = {'CET', 'dummy', 'CET leftover', 'dummy leftover', 'miss'};
        onsets = {
            CET.onset
            dummy.onset
            CET.onset + CET.RT
            dummy.onset + dummy.RT
            miss.onset}';
        durations = {
            CET.RT
            dummy.RT
            CET.duration - CET.RT
            dummy.duration - dummy.RT
            miss.duration}';
    end

    %% Save output

    if ~exist(outdir, 'dir')
       mkdir(outdir)
    end
    
    save(fullfile(outdir, ['sub-' subject '-multiple-conditions-cet.mat']), ...
        'names', 'onsets', 'durations');
    
    clearvars -except names onsets durations

end
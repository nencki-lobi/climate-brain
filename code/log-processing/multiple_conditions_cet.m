function multiple_conditions_cet(logdir, subject)

    %% Initial setup
    
    pat = [subject, '*-cet-*.log'];
    l = dir(fullfile(logdir, pat)).name;
    logfile = fullfile(logdir, l);
    
    pat = [subject, '*-cet-*custom.txt'];
    c = dir(fullfile(logdir, pat)).name;
    customfile = fullfile(logdir, c);
    
    %% Read logfile
    
    txt = readlines(logfile);
    
    ishead = startsWith(txt,'Subject');
    isbody = startsWith(txt, subject);
    
    head = txt(ishead);
    body = txt(isbody);
    
    splited = cellfun(@(x) strsplit(x, '\t'), body, 'UniformOutput', false);
    cropped = cellfun(@(x) x(1:5), splited, 'UniformOutput', false);
    reduced = vertcat(cropped{:});
    
    header = strsplit(head, '\t');
    header = header(1:5);
    
    L = cell2table(reduced, "VariableNames", header);
    
    L.("Event Type") = categorical(L.("Event Type"));
    L.Time = str2double(L.Time);
    
    firstPulse = find(L.("Event Type") == 'Pulse', 1);
    L.Onset = (L.Time-L.Time(firstPulse))/10000;
    
    % Remove (no longer needed) pulse events
    ispulse = L.("Event Type") == 'Pulse';
    L = L(~ispulse, :);
    
    %% Read custom file
    
    C = readtable(customfile, ReadVariableNames = false);
    C.Properties.VariableNames = ["Code","Response"];
    
    %% Calculate duration

    dur = 10; % trial duration
    
    % Find all stimulus events
    isstimulus = L.("Event Type") == 'Picture';
    
    % Add response information from the custom file
    L(:, "Response") = {''};
    L(isstimulus, "Response") = C.Response;
    
    % Find all hit & miss events
    ishit = matches(L.Response,'LEFT') | matches(L.Response,'RIGHT');
    ismiss = matches(L.Response,'NONE');
    
    h = find(isstimulus & ishit);
    m = find(isstimulus & ismiss);
    
    % Calculate duration
    L(:, "Duration") = {NaN};
    L(h, "Duration") = L(h+1, "Onset") - L(h, "Onset"); % For hits, calculate time to first response
    L(m, "Duration") = {dur}; % For misses, set duration to a fixed value
    
    % Remove (no longer needed) response events
    isresponse = L.("Event Type") == 'Response';
    L = L(~isresponse, :);
    
    %% Onsets & durations
    
    CET = L((startsWith(L.Code,'m') | startsWith(L.Code,'c')) & ~matches(L.Response, 'NONE'), :);
    dummy = L((startsWith(L.Code,'dl') | startsWith(L.Code,'dr')) & ~matches(L.Response, 'NONE'), :);
    miss = L(matches(L.Response, 'NONE'), :);
    
    if isempty(miss)
        names = {'CET', 'dummy', 'CET leftover', 'dummy leftover'};
        onsets = {
            CET.Onset
            dummy.Onset
            CET.Onset + CET.Duration
            dummy.Onset + dummy.Duration}';
        durations = {
            CET.Duration
            dummy.Duration
            dur - CET.Duration
            dur - dummy.Duration}';
    else
        names = {'CET', 'dummy', 'CET leftover', 'dummy leftover', 'miss'};
        onsets = {
            CET.Onset
            dummy.Onset
            CET.Onset + CET.Duration
            dummy.Onset + dummy.Duration
            miss.Onset}';
        durations = {
            CET.Duration
            dummy.Duration
            dur - CET.Duration
            dur - dummy.Duration
            miss.Duration}';
    end
    
    %% Parameters
    
    code2money = dictionary({'m0','m1','m2','m3','m4','m5'},[0, 10, 50, 80, 100, 120]);
    code2carbon = dictionary({'c0','c1','c2','c3','c4','c5'},[0, 2, 10, 25, 40, 50]);
    
    CET.Money = code2money( extract(CET.Code, "m" + digitsPattern(1)) );
    CET.Carbon = code2carbon( extract(CET.Code, "c" + digitsPattern(1)) );
    
    dummy.Money = zeros(height(dummy),1);
    dummy.Carbon = zeros(height(dummy),1);
    
    %% Save output

    outdir = './code/first-level/multiple-conditions-cet';

    if ~exist(outdir, 'dir')
       mkdir(outdir)
    end
    
    save(fullfile(outdir, ['sub-' subject '-multiple-conditions-cet.mat']), ...
        'names', 'onsets', 'durations');
    
    clearvars -except study names onsets durations

end

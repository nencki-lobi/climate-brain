function multiple_conditions_stories(logdir, subject, run)

    %% Initial setup
    
    pat = [subject, '*stories*', run, '*.log'];
    l = dir(fullfile(logdir, pat)).name;
    logfile = fullfile(logdir, l);
    
    %% Read logfile
    
    txt = readlines(logfile);
    
    ANG = {'ANG8', 'ANG20', 'ANG17', 'ANG30', 'ANG25', 'ANG6', 'ANG9', 'ANG1', 'ANG12', 'ANG3', 'ANG21', 'ANG7'};
    HOP = {'HOP23', 'HOP15', 'HOP27', 'HOP13', 'HOP17', 'HOP26', 'HOP5', 'HOP11', 'HOP19', 'HOP7', 'HOP22', 'HOP16'};
    NEU = {'NEU14', 'NEU30', 'NEU9', 'NEU15', 'NEU1', 'NEU21', 'NEU29', 'NEU23', 'NEU6', 'NEU12', 'NEU24', 'NEU11'};
    CON = {'NEU26', 'NEU16', 'NEU4', 'NEU25', 'NEU3', 'NEU18', 'NEU10', 'NEU22', 'NEU17', 'NEU27', 'NEU2', 'NEU5'};
    
    if any(contains(txt, ANG))
        EMO = ANG;
    elseif any(contains(txt, HOP))
        EMO = HOP;
    elseif any(contains(txt, NEU))
        EMO = NEU;
    end
    
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
    
    %% Onsets & durations
    
    stories = L((matches(L.Code, EMO) | matches(L.Code, CON)),:);
    isEMO = matches(stories.Code, EMO);
    isCON = matches(stories.Code, CON);
    
    questions = L(matches(L.Code, 'Valence'),:);
    
    names = {'SEMO', 'SCON', 'Q'};
    onsets = {stories.Onset(isEMO), stories.Onset(isCON), questions.Onset};
    durations = {15, 15, 11};
    
    %% Parameters
    
    responses = L(contains(L.Code, 'Response'),:);
    
    stories.Valence = responses.Code(1:2:end);
    stories.Arousal = responses.Code(2:2:end);
    
    stories.Valence = erase(stories.Valence,'Valence Response: ');
    stories.Arousal = erase(stories.Arousal,'Arousal Response: ');
    
    %% Save output

    outdir = './output/multiple-conditions-stories';

    if ~exist(outdir, 'dir')
       mkdir(outdir)
    end
    
    % save(fullfile(outdir, [subject '-multiple-conditions-stories-' run '.mat']), ...
    save(fullfile(outdir, ['multiple-conditions-stories-' run '.mat']), ...
        'names', 'onsets', 'durations');
    
    clearvars -except study names onsets durations

end

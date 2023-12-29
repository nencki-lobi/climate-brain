%% Initial setup

logdir = './data/logs/';
subject = '2711a'; %% choose subject

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

%% Read custom file

C = readtable(customfile, ReadVariableNames = false);
C.Properties.VariableNames = ["Code","Response"];

%% Onsets & durations

CET = L(startsWith(L.Code,'m') | startsWith(L.Code,'c'),:);
dummy = L(startsWith(L.Code,'dl') | startsWith(L.Code,'dr'),:);

names = {'CET', 'dummy'};
onsets = {CET.Onset, dummy.Onset};
durations = {10, 10};

%% Parameters

code2money = dictionary({'m0','m1','m2','m3','m4','m5'},[0, 10, 50, 80, 100, 120]);
code2carbon = dictionary({'c0','c1','c2','c3','c4','c5'},[0, 2, 10, 25, 40, 50]);

CET.Money = code2money( extract(CET.Code, "m" + digitsPattern(1)) );
CET.Carbon = code2carbon( extract(CET.Code, "c" + digitsPattern(1)) );

dummy.Money = zeros(height(dummy),1);
dummy.Carbon = zeros(height(dummy),1);

%% Save output

% save(['./output/' subject '-multiple-conditions-cet.mat'], ...
save('./output/multiple-conditions-cet.mat', ...
    'names', 'onsets', 'durations');

clearvars -except study names onsets durations

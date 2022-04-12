%% Gray data prep (Fieldtrip) 
%formatting datas to obtain a format compatible with Fieldtrip
% Marion Ducret 180222 

clear

%% Define path & number of trials in session 

monkey = input('Which Monkey? ','s'); %Pick monkey
date = input('Which date? ','s'); %Pick date

path = strcat('/Volumes/Procyk_Data/Charlie Gray Data/',monkey,'/',date,'/session01/');
cd(path); % Go to the data
filenames = dir('*.mat');
filenames(end,:) = [];%supp recording_info
filenames(end,:) = [];%supp trial_info
N_files = numel(filenames);

f = struct2cell(filenames);%fropm structure format to cells for indexing


%% Load trial & recording infos

load(strcat(path,'trial_info.mat'))
load(strcat(path,'recording_info.mat'))

%% Index of trials sorted by type

Correct = find(trial_info.behavioral_response == 1);
Incorrect = find(trial_info.behavioral_response == 0);
Vide = find(isnan(trial_info.behavioral_response));

%% select ROI
ROI = unique(recording_info.area);
ROI = ROI (1, [3,4,5,6,16,18,19,20,23,24,25]);%enter manually ROI wanted

%% Incorrect trials

SavePath = strcat('/Users/marionducret/Desktop/Gray analysis/',monkey,'/Ephys_data/',date,'/Incorrect/');

%create time date according to sampling  rate (32kHz) & add every trial in
%a cell of the same structure
for i = Incorrect 
    load(strcat(path,char(f(1,i))));
    v = (0:(length(raw_data(1,:))-1)) ; 
    time_data = (v * 0.03125)/1000 ; %in secondes
    ephys_data.trial{1,i} = raw_data;
    ephys_data.time{1,i} = time_data;
end

ephys_data.fsample = 32000;
ephys_data.label = string(num2cell(recording_info.channel_numbers.'));%convert double to string
ephys_data.label_area = recording_info.area.';

%supp empty cells
inc_ephys_data = ephys_data ;
idx = cellfun('isempty',inc_ephys_data.trial);
inc_ephys_data.trial(idx) = [];
idx = cellfun('isempty',inc_ephys_data.time);
inc_ephys_data.time(idx) = [];

%creation of the final structure sorted by electrode for every area
ephys_data = [];

for i = ROI
    area = string(i);
    idx = find(recording_info.area == area);
    if area == 'a9/46D' % syntaxe issue for saving
        area = 'a9-46D';  
    elseif area == 'a9/46V'  
        area = 'a9-46V'; 
    else 
         disp('');
    end
        for ii = 1 : length(inc_ephys_data.trial)%trials number 
             ephys_data.time{1,ii}(1,:) = inc_ephys_data.time{1,ii}(1,:);
             x = 1;
             y = 1;
                for iii = idx%electrode by electrode
                    ephys_data.label {x,1} = string(recording_info.channel_numbers(1,iii));
                    x = x+1;
                    ephys_data.trial{1,ii}(y,:) = inc_ephys_data.trial{1,ii}(iii,:);
                    y = y+1;
                end
         end
    ephys_data.fsample = 32000;
    save(strcat(SavePath,area,'_',date,'_ephys_data.mat'),'ephys_data', '-v7.3', '-nocompression');
    ephys_data = [];
end

%% Correct trials
% same than above but for correct trials

SavePath2 = strcat('/Users/marionducret/Desktop/Gray analysis/',monkey,'/Ephys_data/',date,'/Correct/');

ephys_data = [];

for i = Correct 
    load(strcat(path,char(f(1,i))));
    v = (0:(length(raw_data(1,:))-1)) ; 
    time_data = (v * 0.03125)/1000 ; 
    ephys_data.trial{1,i} = raw_data;
    ephys_data.time{1,i} = time_data;
end

ephys_data.fsample = 32000;
ephys_data.label = string(num2cell(recording_info.channel_numbers.'));
ephys_data.label_area = recording_info.area.';

c_ephys_data = ephys_data ;
idx = cellfun('isempty',c_ephys_data.trial);
c_ephys_data.trial(idx) = [];
idx = cellfun('isempty',c_ephys_data.time);
c_ephys_data.time(idx) = [];

ephys_data = [];


for i = ROI
    idx = find(recording_info.area == string(i));
    area = string(i);
    if area == 'a9/46D' 
        area = 'a9-46D';  
    elseif area == 'a9/46V'  
        area = 'a9-46V'; 
    else 
        disp('');
    end
        for ii = 1 : length(c_ephys_data.trial)
             ephys_data.time{1,ii}(1,:) = c_ephys_data.time{1,ii}(1,:);
             x = 1;
             y = 1;
                for iii = idx
                    ephys_data.label {x,1} = string(recording_info.channel_numbers(1,iii));
                    x = x+1;
                    ephys_data.trial{1,ii}(y,:) = c_ephys_data.trial{1,ii}(iii,:);
                    y = y+1;
                end
         end
    ephys_data.fsample = 32000;
    save(strcat(SavePath2,area,'_',date,'_ephys_data.mat'),'ephys_data', '-v7.3', '-nocompression');
    ephys_data = [];
end


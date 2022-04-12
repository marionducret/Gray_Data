%% Gray data spike rate analysis
% Marion Ducret 090422

clear

%% Load specific files

monkey = input('Which Monkey? ','s'); %Pick monkey
date = input('Which date? ','s'); %Pick date

path = strcat('/Volumes/Procyk_Data/Charlie Gray Data/',monkey,'/',date,'/session01/');
cd(path); % Go to the data

filenames = dir('*.mat');
filenames(end,:) = [];%supp recording_info
filenames(end,:) = [];%supp trial_info
N_files = numel(filenames);

f = struct2cell(filenames);%from structure to cells for indexing


%% Load trial & recording infos

load(strcat(path,'trial_info.mat'))
load(strcat(path,'recording_info.mat'))

%% all_spike_times matrix preparation

SavePath = strcat('/Volumes/Gold Lacie - Backup Data/Marion/Gray data spike/',monkey,'/');

all_MUA_times = cell(1,N_files);%preallocating for speed 
all_SUA_times = cell(1,N_files);

for i = 1 : N_files 
    load(strcat(path,char(f(1,i))));

    MUA_times = spike_times(:,1);
    idx = cellfun('isempty',MUA_times); 
    MUA_times(:,2) = num2cell(recording_info.channel_numbers');
    MUA_times(:,3) = num2cell(recording_info.area');
    MUA_times(idx,:) = [];
    
    
    SUA_times = spike_times(:,2);
    idx = cellfun('isempty',SUA_times); 
    SUA_times(:,2) = num2cell(recording_info.channel_numbers');%type of trial (1 = correct / 0 = incorrect / Nan = empty)
    SUA_times(:,3) = num2cell(recording_info.area');
    SUA_times(idx,:) = [];


    all_MUA_times{1,i} = MUA_times ;
    all_MUA_times{2,i} = trial_info.behavioral_response(1,i);
    all_SUA_times{1,i} = SUA_times ;
    all_SUA_times{2,i} = trial_info.behavioral_response(1,i);

end

save(strcat(SavePath,date,'_spike_data.mat'),'all_MUA_times','all_SUA_times', '-v7.3', '-nocompression');

%% Analyse

clear 

%% load data

monkey = input('Which Monkey? ','s'); %Pick monkey
date = input('Which date? ','s'); %Pick date

path = strcat('/Volumes/Gold Lacie - Backup Data/Marion/Gray data spike/',monkey,'/');
load(strcat(path,date,'_spike_data.mat'));

load(strcat('/Volumes/Procyk_Data/Charlie Gray Data/',monkey,'/',date,'/session01/trial_info.mat'));
load(strcat('/Volumes/Procyk_Data/Charlie Gray Data/',monkey,'/',date,'/session01/recording_info.mat'));

%% spike rate

%MUA

idx = find(cellfun('isempty',all_MUA_times(1,:)));%remove empty trials
all_MUA_times(:,idx)=[];

for i = 1 : length(all_MUA_times)
    trial = all_MUA_times{1,i};
        for ii = 1 : length(trial(:,1))
            temp = trial{ii,1};
            Max = max(temp);
            num = floor(Max/1000);%round to the floor
            tbin = (2000:2000:num*2000);%bin of 2s 
            spike_rate = cell(1,length(tbin));
            x = 1 ;
            if isempty(tbin)
                spike_rate(1,x) = cellstr('NaN');
            else 
                for iii = tbin
                    spike_rate(1,x) = num2cell(sum((temp>iii-2000) & (temp<iii)));
                    x = x+1;
                end
            end 
            trial{ii,4} = spike_rate; 
        end
    all_MUA_times{1,i}(:,4) = trial(:,4);
end 

%SUA

idx = find(cellfun('isempty',all_SUA_times(1,:)));
all_SUA_times(:,idx)=[];

for i = 1 : length(all_SUA_times)
    trial = all_SUA_times{1,i};
        for ii = 1 : length(trial(:,1))
            temp = trial{ii,1};
            Max = max(temp);
            num = floor(Max/2000);
            tbin = (2000:2000:num*2000); 
            spike_rate = cell(1,length(tbin));
            x = 1 ;
            if isempty(tbin)
                spike_rate(1,x) = cellstr('NaN');
            else 
                for iii = tbin
                    spike_rate(1,x) = num2cell(sum((temp>iii-2000) & (temp<iii)));
                    x = x+1;
                end
            end 
            trial{ii,4} = spike_rate; 
        end
    all_SUA_times{1,i}(:,4) = trial(:,4);
end 

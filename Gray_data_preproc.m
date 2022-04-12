%% Gray data preprocessing

% Marion Ducret 090222 

clear

%% Load specific files (Fieldtrip format)

monkey = input('Which Monkey? ','s'); %Pick monkey
date = input('Which date? ','s'); %Pick date

path = strcat('/Volumes/Procyk_Data_2/PhD_Marion/Gray analysis/',monkey,'/Ephys_data/',date,'/');
cd(path); % Go to the data

area = input('Which area? ','s'); 

Correct = load(strcat(path,'Correct/',area,'_',date,'_ephys_data.mat'));
Incorrect = load(strcat(path,'Incorrect/',area,'_',date,'_ephys_data.mat'));

load(strcat('/Volumes/Procyk_Data/Charlie Gray Data/',monkey,'/',date,'/session01/trial_info.mat'));
load(strcat('/Volumes/Procyk_Data/Charlie Gray Data/',monkey,'/',date,'/session01/recording_info.mat'));

%% Define delay time

trial_info.delay = trial_info.match_on - trial_info.sample_off;

u = trial_info.delay;
uni = unique(trial_info.delay);

u(isnan(u))=[];
uni(isnan(uni))=[];

n = histc(u,uni);%occurence number

trial_info.delay_occ = [uni(:) n(:)];%table with delay value and its occurence number

%% Under sampling (-> 1kHz)

    for i = 1 : length(Correct.ephys_data.trial) 
        Correct.ephys_data.time{1,i} = downsample(Correct.ephys_data.time{1,i},32);
        temp = [];
            for ii = 1 : length(Correct.ephys_data.label)
                temp(ii,:) = downsample(Correct.ephys_data.trial{1,i}(ii,:),32);
            end
        Correct.ephys_data.trial{1,i} = temp;
    end

Correct.ephys_data.fsample = 1000;%new sampling rate

    for i = 1 : length(Incorrect.ephys_data.trial) 
        Incorrect.ephys_data.time{1,i} = downsample(Incorrect.ephys_data.time{1,i},32);
        temp = [];
            for ii = 1 : length(Incorrect.ephys_data.label)
                temp(ii,:) = downsample(Incorrect.ephys_data.trial{1,i}(ii,:),32);
            end
        Incorrect.ephys_data.trial{1,i} = temp;
    end  

Incorrect.ephys_data.fsample = 1000;
    
%% Cut trials on a specific time 

C = find(trial_info.behavioral_response == 1);
I = find(trial_info.behavioral_response == 0);

% Presample + sample + delay CORRECT

for ch = 1:length(Correct.ephys_data.label)
    for i = 1 : length(Correct.ephys_data.trial) 
         ii = C(1,i);
         trial = Correct.ephys_data.trial{1,i}(ch,:);
         time = Correct.ephys_data.time{1,i}(1,:);
         sample_on = trial_info.sample_on(1,ii);
         sample_off = trial_info.sample_off(1,ii);
         match_on = trial_info.match_on(1,ii);
         start_time = (sample_on - 700)/1000;%in secondes
         if start_time < 0
             start_time = 0;
         end
         end_time = (match_on + 500)/1000;
         correct.trialinfo{1,i} = [sample_on-start_time,sample_off-start_time,match_on-start_time];% trialinfo (1 = sample_on / 2 = sample-off / 3 = match_on)
         start_point = find((time(1,:) == start_time));
         end_point = find(time(1,:) == end_time);
         correct.trial{ch,i} = trial(:,start_point:end_point);
         correct.time{1,i} = time(:,start_point:end_point);
                for ii = 1 : length(correct.time{1,i})
                    correct.time{1,i}(1,ii) = correct.time{1,i}(1,ii) - start_time;
                end
    end
end

tf_c = isa(Correct.ephys_data.label,'double'); %knowing if data class is 'double' -> if tf = 1 (TRUE) if tf = 0 (FALSE)
if tf_c == 1 
    correct.label = cellstr(string(Correct.ephys_data.label));
else 
    correct.label = cellstr(Correct.ephys_data.label);%convert format to cell array of character vectors
end  

correct.fsample = 1000;

%Create one variable per electrode in the structure + preprocessing by electrode
y = 1;
for i = correct.label.'
        correct.(['ch' num2str(cell2mat(i))]) = [];
        correct.(['ch' num2str(cell2mat(i))]).time = correct.time;
        correct.(['ch' num2str(cell2mat(i))]).fsample = correct.fsample;
        correct.(['ch' num2str(cell2mat(i))]).trial = correct.trial(y,:);
        correct.(['ch' num2str(cell2mat(i))]).label = correct.label(y,:);
        y = y+1;
        cfg = [];
        pp_correct.(['ch' num2str(cell2mat(i))]) = ft_preprocessing(cfg, correct.(['ch' num2str(cell2mat(i))]));
        pp_correct.(['ch' num2str(cell2mat(i))]).trialinfo = correct.trialinfo;

end


% Presample + sample + delay INCORRECT

for ch = 1:length(Incorrect.ephys_data.label)
    for i = 1 : length(Incorrect.ephys_data.trial) 
         ii = I(1,i);
         trial = Incorrect.ephys_data.trial{1,i}(ch,:);
         time = Incorrect.ephys_data.time{1,i}(1,:);
         sample_on = trial_info.sample_on(1,ii);
         sample_off = trial_info.sample_off(1,ii);
         match_on = trial_info.match_on(1,ii);
         start_time = (sample_on - 700)/1000;%passage en secondes
         if start_time < 0
             start_time = 0;
         end
         end_time = (match_on + 500)/1000;
         incorrect.trialinfo{1,i} = [sample_on-start_time,sample_off-start_time,match_on-start_time];% trialinfo (1 = sample_on / 2 = sample-off / 3 = match_on)
         start_point = find((time(1,:) == start_time));
         end_point = find(time(1,:) == end_time);
         incorrect.trial{ch,i} = trial(:,start_point:end_point);
         incorrect.time{1,i} = time(:,start_point:end_point);
                for ii = 1 : length(incorrect.time{1,i})
                    incorrect.time{1,i}(1,ii) = incorrect.time{1,i}(1,ii) - start_time;
                end
    end
end

tf_c = isa(Incorrect.ephys_data.label,'double'); 
    incorrect.label = cellstr(string(Incorrect.ephys_data.label));
else 
    incorrect.label = cellstr(Incorrect.ephys_data.label);
end  

incorrect.fsample = 1000;

%Create one variable per electrode in the structure + preprocessing by electrode
y = 1;
for i = incorrect.label.'
        incorrect.(['ch' num2str(cell2mat(i))]) = [];
        incorrect.(['ch' num2str(cell2mat(i))]).time = incorrect.time;
        incorrect.(['ch' num2str(cell2mat(i))]).fsample = incorrect.fsample;
        incorrect.(['ch' num2str(cell2mat(i))]).trial = incorrect.trial(y,:);
        incorrect.(['ch' num2str(cell2mat(i))]).label = incorrect.label(y,:);
        y = y+1;
        cfg = [];
        pp_incorrect.(['ch' num2str(cell2mat(i))]) = ft_preprocessing(cfg, incorrect.(['ch' num2str(cell2mat(i))]));
        pp_incorrect.(['ch' num2str(cell2mat(i))]).trialinfo = incorrect.trialinfo;

end

%SAVE

SavePath = strcat('/Volumes/Gold Lacie - Backup Data/Marion/pp data/',monkey,'/');
save(strcat(SavePath,area,'_',date,'_pp_data.mat'),'pp_correct','pp_incorrect', '-v7.3', '-nocompression');

%% Cut time : delay part / pre-sample part

C = find(trial_info.behavioral_response == 1);
I = find(trial_info.behavioral_response == 0);

%Delay 

for ch = 1:length(Correct.ephys_data.label)
    for i = 1 : length(Correct.ephys_data.trial) 
         ii = C(1,i);
         trial = Correct.ephys_data.trial{1,i}(ch,:);
         time = Correct.ephys_data.time{1,i}(1,:);
         sample_off = trial_info.sample_off(1,ii);
         start_time = (sample_off - 1000)/1000;%passage en secondes
         end_time = (sample_off + 2000)/1000;
         start_point = find((time(1,:) == start_time));
         end_point = find(time(1,:) == end_time);
         delay_correct.trial{ch,i} = trial(:,start_point:end_point);
         delay_correct.time{1,i} = time(:,start_point:end_point);
                for ii = 1 : length(delay_correct.time{1,i})
                    delay_correct.time{1,i}(1,ii) = delay_correct.time{1,i}(1,ii) - start_time;
                end
    end
end

tf_c = isa(Correct.ephys_data.label,'double'); %savoir si les data sont de type 'double' -> si tf = 1 (VRAI) si tf = 0 (FAUX)
if tf_c == 1 
    delay_correct.label = cellstr(string(Correct.ephys_data.label));
else 
    delay_correct.label = cellstr(Correct.ephys_data.label);%convert format to cell array of character vectors
end  

delay_correct.fsample = 1000;

idx = cellfun('isempty',delay_correct.trial); %supp les cell vides suite à des NaN dans le trial_info
delay_correct.trial(idx) = [];
idx = cellfun('isempty',delay_correct.time); 
delay_correct.time(idx) = [];

%Créer une variable par électrode au sein de la structure + faire le
%préprocessing par électrode
y = 1;
for i = delay_correct.label.'
        delay_correct.(['ch' num2str(cell2mat(i))]) = [];
        delay_correct.(['ch' num2str(cell2mat(i))]).time = delay_correct.time;
        delay_correct.(['ch' num2str(cell2mat(i))]).fsample = delay_correct.fsample;
        delay_correct.(['ch' num2str(cell2mat(i))]).trial = delay_correct.trial(y,:);
        delay_correct.(['ch' num2str(cell2mat(i))]).label = delay_correct.label(y,:);
        y = y+1;
        cfg = [];
        pp_delay_correct.(['ch' num2str(cell2mat(i))]) = ft_preprocessing(cfg, delay_correct.(['ch' num2str(cell2mat(i))]));
        
end

for ch = 1:length(Correct.ephys_data.label)
    for i = 1 : length(Incorrect.ephys_data.trial)
     ii = I(1,i);
     trial = Incorrect.ephys_data.trial{1,i}(ch,:);
     time = Incorrect.ephys_data.time{1,i}(1,:);
     sample_off = trial_info.sample_off(1,ii);
     start_time = (sample_off - 1000)/1000;
     end_time = (sample_off + 2000)/1000;
     start_point = find(time(1,:) == start_time);
     end_point = find(time(1,:) == end_time);
     delay_incorrect.trial{ch,i} = trial(:,start_point:end_point);
     delay_incorrect.time{1,i} = time(:,start_point:end_point);
        for ii = 1 : length(delay_incorrect.time{1,i})
            delay_incorrect.time{1,i}(1,ii) = delay_incorrect.time{1,i}(1,ii) - start_time;
        end
    end
end

tf_inc = isa(Incorrect.ephys_data.label,'double'); %savoir si les data sont de type 'double' -> si tf = 1 (VRAI) si tf = 0 (FAUX)
if tf_inc == 1 
    delay_incorrect.label = cellstr(string(Incorrect.ephys_data.label));
else 
    delay_incorrect.label = cellstr(Incorrect.ephys_data.label);%convert format to cell array of character vectors
end 

delay_incorrect.fsample = 1000;

idx = cellfun('isempty',delay_incorrect.trial); 
delay_incorrect.trial(idx) = [];
idx = cellfun('isempty',delay_incorrect.time); 
delay_incorrect.time(idx) = [];


y = 1;
for i = delay_incorrect.label.'
        delay_incorrect.(['ch' num2str(cell2mat(i))]) = [];
        delay_incorrect.(['ch' num2str(cell2mat(i))]).time = delay_incorrect.time;
        delay_incorrect.(['ch' num2str(cell2mat(i))]).fsample = delay_incorrect.fsample;
        delay_incorrect.(['ch' num2str(cell2mat(i))]).trial = delay_incorrect.trial(y,:);
        delay_incorrect.(['ch' num2str(cell2mat(i))]).label = delay_incorrect.label(y,:);
        y = y+1;
        cfg = [];
        pp_delay_incorrect.(['ch' num2str(cell2mat(i))]) = ft_preprocessing(cfg, delay_incorrect.(['ch' num2str(cell2mat(i))])); 
end

%Pre-sample

for ch = 1:length(Correct.ephys_data.label)
    for i = 1 : length(Correct.ephys_data.trial)
     ii = C(1,i);
     trial = Correct.ephys_data.trial{1,i}(ch,:);
     time = Correct.ephys_data.time{1,i}(1,:);
     sample_on = trial_info.sample_on(1,ii);
     start_time = (sample_on - 500)/1000;
     end_time = sample_on/1000;
     start_point = find(time(1,:) == start_time);
     end_point = find(time(1,:) == end_time);
     presample_correct.trial{ch,i} = trial(:,start_point:end_point);
     presample_correct.time{1,i} = time(:,start_point:end_point);
        for ii = 1 : length(presample_correct.time{1,i})
            presample_correct.time{1,i}(1,ii) = presample_correct.time{1,i}(1,ii) - start_time;
        end
    end
end

if tf_c == 1
    presample_correct.label = cellstr(string(Correct.ephys_data.label));
else 
    presample_correct.label = cellstr(Correct.ephys_data.label);%convert format to cell array of character vectors
end 

presample_correct.fsample = 1000;

idx = cellfun('isempty',presample_correct.trial); 
presample_correct.trial(idx) = [];
idx = cellfun('isempty',presample_correct.time); 
presample_correct.time(idx) = [];

y = 1;
for i = presample_correct.label.'
        presample_correct.(['ch' num2str(cell2mat(i))]) = [];
        presample_correct.(['ch' num2str(cell2mat(i))]).time = presample_correct.time;
        presample_correct.(['ch' num2str(cell2mat(i))]).fsample = presample_correct.fsample;
        presample_correct.(['ch' num2str(cell2mat(i))]).trial = presample_correct.trial(y,:);
        presample_correct.(['ch' num2str(cell2mat(i))]).label = presample_correct.label(y,:);
        y = y+1;
        cfg = [];
        pp_presample_correct.(['ch' num2str(cell2mat(i))]) = ft_preprocessing(cfg, presample_correct.(['ch' num2str(cell2mat(i))])); 
end

for ch = 1:length(Correct.ephys_data.label)    
    for i = 1 : length(Incorrect.ephys_data.trial)
     ii = I(1,i);
     trial = Incorrect.ephys_data.trial{1,i}(ch,:);
     time = Incorrect.ephys_data.time{1,i}(1,:);
     sample_on = trial_info.sample_on(1,ii);
     start_time = (sample_on - 500)/1000;
     end_time = sample_on/1000;
     start_point = find(time(1,:) == start_time);
     end_point = find(time(1,:) == end_time);
     presample_incorrect.trial{ch,i} = trial(:,start_point:end_point);
     presample_incorrect.time{1,i} = time(:,start_point:end_point);
        for ii = 1 : length(presample_incorrect.time{1,i})
            presample_incorrect.time{1,i}(1,ii) = presample_incorrect.time{1,i}(1,ii) - start_time;
        end
    end
end

if tf_inc == 1
    presample_incorrect.label = cellstr(string(Incorrect.ephys_data.label));
else 
    presample_incorrect.label = cellstr(Incorrect.ephys_data.label);%convert format to cell array of character vectors
end 

presample_incorrect.fsample = 1000;

idx = cellfun('isempty',presample_incorrect.trial); 
presample_incorrect.trial(idx) = [];
idx = cellfun('isempty',presample_incorrect.time); 
presample_incorrect.time(idx) = [];

y = 1;
for i = presample_incorrect.label.'
        presample_incorrect.(['ch' num2str(cell2mat(i))]) = [];
        presample_incorrect.(['ch' num2str(cell2mat(i))]).time = presample_incorrect.time;
        presample_incorrect.(['ch' num2str(cell2mat(i))]).fsample = presample_incorrect.fsample;
        presample_incorrect.(['ch' num2str(cell2mat(i))]).trial = presample_incorrect.trial(y,:);
        presample_incorrect.(['ch' num2str(cell2mat(i))]).label = presample_incorrect.label(y,:);
        y = y+1;
        cfg = [];
        pp_presample_incorrect.(['ch' num2str(cell2mat(i))]) = ft_preprocessing(cfg, presample_incorrect.(['ch' num2str(cell2mat(i))])); 
end


%SAVE

SavePath = strcat('/Volumes/Procyk_Data_2/PhD_Marion/Gray analysis/',monkey,'/Preprocessed/');
save(strcat(SavePath,area,'_',date,'_pp_data.mat'),'pp_delay_correct','pp_delay_incorrect','pp_presample_correct','pp_presample_incorrect', '-v7.3', '-nocompression');
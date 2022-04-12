%% Gray data spike rate analysis

% Marion Ducret 040422 

clear

%% Load specific files (Fieldtrip format)

monkey = input('Which Monkey? ','s'); %Pick monkey
date = input('Which date? ','s'); %Pick date

%path = strcat('/Volumes/Procyk_Data/Charlie Gray Data/',monkey,'/Ephys_data/',date,'/');
path = strcat('/Volumes/Procyk_Data_2/PhD_Marion/Gray analysis/',monkey,'/Ephys_data/',date,'/');
cd(path); % Go to the data

area = input('Which area? ','s'); 

Correct = load(strcat(path,'Correct/',area,'_',date,'_ephys_data.mat'));
Incorrect = load(strcat(path,'Incorrect/',area,'_',date,'_ephys_data.mat'));

load(strcat('/Volumes/Procyk_Data/Charlie Gray Data/',monkey,'/',date,'/session01/trial_info.mat'));
load(strcat('/Volumes/Procyk_Data/Charlie Gray Data/',monkey,'/',date,'/session01/recording_info.mat'));


%% ERP correct/incorrect

cfg = [];
        cfg.keeptrials         = 'yes';
        cfg.removemean         = 'yes';
        
pp_delay_correct.timelock = ft_timelockanalysis(cfg, pp_delay_correct);
pp_delay_correct.timelock.trial = squeeze(pp_delay_correct.timelock.trial); %permet de passer de 3 à 2 dimensions         

cfg = [];
        cfg.keeptrials         = 'no'; %mean
        cfg.removemean         = 'yes';

pp_delay_correct.timelock2 = ft_timelockanalysis(cfg, pp_delay_correct);        

cfg = [];
        cfg.keeptrials         = 'yes';
        cfg.removemean         = 'yes';
      
pp_delay_incorrect.timelock = ft_timelockanalysis(cfg, pp_delay_incorrect);       
pp_delay_incorrect.timelock.trial = squeeze(pp_delay_incorrect.timelock.trial);          

cfg = [];
        cfg.keeptrials         = 'no';
        cfg.removemean         = 'yes';
        
pp_delay_incorrect.timelock2 = ft_timelockanalysis(cfg, pp_delay_incorrect);               
        
   figure
        subplot(2,1,1);
        plot(pp_delay_correct.timelock2.time, pp_delay_correct.timelock2.avg, 'Color', [1 0 0]);
        vline(1000)
        text(1000,-0.00003,'sample off')
        ylabel('Volts');
        title(sprintf('Delay period in correct trial (%s)',area));
        ylim([-0.00006,0.00004]);
        subplot(2,1,2);
        plot(pp_delay_incorrect.timelock2.time, pp_delay_incorrect.timelock2.avg, 'Color', [1 0 0]);
        vline(1000)
        text(1000,-0.00003,'sample off');
        ylabel('Volts');
        xlabel('Time(ms)');
        title(sprintf('Delay period in incorrect trial (%s)',area));
        ylim([-0.00006,0.00004]);
        saveas(gcf,'subplots','pdf') %leaves white border
        
       
%% ERP short delay/long delay (correct)

%enlève les potentiels NaN 
idx = isnan(trial_info.delay); 
trial_info.delay(idx) = [];

m = median(trial_info.delay);

Short = find(trial_info.delay <= m);
Long = find(trial_info.delay > m);

for i = 1 : length(pp_delay_correct.trial)
    if ismember(i, Short) == 1
        short_pp_delay_correct.trial(1,i) = pp_delay_correct.trial(1,i);
        short_pp_delay_correct.time(1,i) = pp_delay_correct.time(1,i);
    end
end

for i = 1 : length(pp_delay_correct.trial)
    if ismember(i, Long) == 1
        long_pp_delay_correct.trial(1,i) = pp_delay_correct.trial(1,i);
        long_pp_delay_correct.time(1,i) = pp_delay_correct.time(1,i);
    end
end

idx = cellfun('isempty',short_pp_delay_correct.trial); 
short_pp_delay_correct.trial(idx) = [];
idx = cellfun('isempty',short_pp_delay_correct.time); 
short_pp_delay_correct.time(idx) = [];
short_pp_delay_correct.label = pp_delay_correct.label;
short_pp_delay_correct.fsample = pp_delay_correct.fsample;
short_pp_delay_correct.sampleinfo = pp_delay_correct.sampleinfo;

idx = cellfun('isempty',long_pp_delay_correct.trial); 
long_pp_delay_correct.trial(idx) = [];
idx = cellfun('isempty',long_pp_delay_correct.time); 
long_pp_delay_correct.time(idx) = [];
long_pp_delay_correct.label = pp_delay_correct.label;
long_pp_delay_correct.fsample = pp_delay_correct.fsample;
long_pp_delay_correct.sampleinfo = pp_delay_correct.sampleinfo;


cfg = [];
        cfg.keeptrials         = 'yes';
        cfg.removemean         = 'yes';
       
short_pp_delay_correct.timelock = ft_timelockanalysis(cfg, short_pp_delay_correct);
short_pp_delay_correct.timelock.trial = squeeze(short_pp_delay_correct.timelock.trial); %permet de passer de 3 à 2 dimensions         

cfg = [];
        cfg.keeptrials         = 'no'; %mean
        cfg.removemean         = 'yes';

short_pp_delay_correct.timelock2 = ft_timelockanalysis(cfg, short_pp_delay_correct);        

cfg = [];
        cfg.keeptrials         = 'yes';
        cfg.removemean         = 'yes';
      
long_pp_delay_correct.timelock = ft_timelockanalysis(cfg, long_pp_delay_correct);       
long_pp_delay_correct.timelock.trial = squeeze(long_pp_delay_correct.timelock.trial);          

cfg = [];
        cfg.keeptrials         = 'no';
        cfg.removemean         = 'yes';
        
long_pp_delay_correct.timelock2 = ft_timelockanalysis(cfg, long_pp_delay_correct);               
        
    figure
        subplot(2,1,1);
        %plot(pp_delay_correct.timelock.time, pp_delay_correct.timelock.trial, 'Color', [0.5 0.5 0.5 0.2]);
        %hold on;
        plot(short_pp_delay_correct.timelock2.time, short_pp_delay_correct.timelock2.avg, 'Color', [1 0 0]);
        vline(1000)
        text(1000,-0.00003,'sample off')
        %hold off;
        ylabel('Volts');
        title(sprintf('Short delay period in correct trial (%s)',area));
        ylim([-0.00004,0.00003]);
        subplot(2,1,2);
        %plot(pp_delay_incorrect.timelock.time, pp_delay_incorrect.timelock.trial, 'Color', [0.5 0.5 0.5 0.2]);
        %hold on;
        plot(long_pp_delay_correct.timelock2.time, long_pp_delay_correct.timelock2.avg, 'Color', [1 0 0]);
        vline(1000)
        text(1000,-0.00003,'sample off')
        %hold off;
        ylabel('Volts');
        xlabel('Time(ms)');
        title(sprintf('Long delay period in correct trial (%s)',area));
        ylim([-0.00004,0.00003]);

        
        



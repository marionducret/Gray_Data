%% Gray data re-sampling (undersampling 32kHz -> 1kHz)

% Marion Ducret 030422

clear

monkey = input('Which Monkey? ','s'); %Pick monkey
ch = input('Which channel? ','s');
path = strcat('/Volumes/Procyk_Data_2/PhD_Marion/Gray analysis/',monkey,'/Preprocessed/');
cd(path)
filenames = dir('*.mat');
N_files = numel(filenames);
f = struct2cell(filenames);

for i = 1:N_files
    name = char(f(1,i));
    load(strcat(path,name));

    for ii = 1 : length(pp_delay_correct.(['ch' num2str(ch)]).trial) 
        pp_delay_correct.(['ch' num2str(ch)]).trial{1,ii} = downsample(pp_delay_correct.(['ch' num2str(ch)]).trial{1,ii},32);
        pp_delay_correct.(['ch' num2str(ch)]).time{1,ii} = downsample(pp_delay_correct.(['ch' num2str(ch)]).trial{1,ii},32);
    end

    for ii = 1 : length(pp_delay_incorrect.(['ch' num2str(ch)]).trial) 
        pp_delay_incorrect.(['ch' num2str(ch)]).trial{1,ii} = downsample(pp_delay_incorrect.(['ch' num2str(ch)]).trial{1,ii},32);
        pp_delay_incorrect.(['ch' num2str(ch)]).time{1,ii} = downsample(pp_delay_incorrect.(['ch' num2str(ch)]).trial{1,ii},32);
    end

    for ii = 1 : length(pp_presample_correct.(['ch' num2str(ch)]).trial) 
        pp_presample_correct.(['ch' num2str(ch)]).trial{1,ii} = downsample(pp_presample_correct.(['ch' num2str(ch)]).trial{1,ii},32);
        pp_presample_correct.(['ch' num2str(ch)]).time{1,ii} = downsample(pp_presample_correct.(['ch' num2str(ch)]).trial{1,ii},32);
    end

    for ii = 1 : length(pp_presample_incorrect.(['ch' num2str(ch)]).trial) 
        pp_presample_incorrect.(['ch' num2str(ch)]).trial{1,ii} = downsample(pp_presample_incorrect.(['ch' num2str(ch)]).trial{1,ii},32);
        pp_presample_incorrect.(['ch' num2str(ch)]).time{1,ii} = downsample(pp_presample_incorrect.(['ch' num2str(ch)]).trial{1,ii},32);
    end
    save(name,'pp_delay_correct','pp_delay_incorrect','pp_presample_incorrect','pp_presample_correct','-v7.3', '-nocompression'); 
end





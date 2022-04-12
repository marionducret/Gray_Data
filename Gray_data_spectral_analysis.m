%% Gray data Analysis (LFP + spike) 

% Marion Ducret 160322 
% Adapted from Gray_Data_analysis_MD

clear

%% Define specific arguments

monkey = input('Which Monkey? ','s'); %Pick monkey
date = input('Which date? ','s'); %Pick date
area = input('Which area? ','s'); 


%% Load preprocessed data & trial/recording infos

path = load(strcat('/Volumes/Procyk_Data/Charlie Gray Data/',monkey,'/',date,'/session01/'));
load(strcat(path,'trial_info.mat'));
load(strcat(path,'recording_info.mat'));

clear path

path = strcat('/Volumes/Gold Lacie - Backup Data/Marion/pp data/',monkey,'/');
load(strcat(path,area,'_',date,'_pp_data.mat'));
                       
%% Freq analysis on different trial types (delay period)

%DELAY correct 
clear C_mean_delay I_mean_delay Bin1 Bin2 Bin3 %clear existing vaiables

ch = input('Which channel? ','s');
freqborder = input('Which frequencies? ');
FOI = strcat(string(min(freqborder)),'-',string(max(freqborder)),' Hz');%for plot tittle


cfg = [];
cfg.output         = 'pow';
cfg.method         = 'wavelet';
cfg.keeptrials     = 'no'; 
cfg.trials         = 'all';
cfg.foi            = freqborder; %frequence of interest
cfg.toi            = 0:0.01:3;  
cfg.pad            = 'maxperlen';
test        = ft_freqanalysis(cfg, pp_correct.(['ch' num2str(ch)])) ;

 figure
                    current = squeeze(test.powspctrm(1,:,:)) ;
                    imagesc(test.time,test.freq,current) ; 
                    axis xy
                    xlabel('Time (s)')
                    ylabel('Frequency (Hz)')
                    c = colorbar;
                    caxis ([0, 8e-9])
                    ylabel(c,'Power')
                    %ylim([0,50]);
                    %title(sprintf('Delay period of correct trials - %s (%s)',monkey, date));
                   
cut = round(length(pp_delay_correct.(['ch' num2str(ch)]).trial)/3);%cut by three the trial number

cfg = [];
cfg.output         = 'pow';
cfg.method         = 'wavelet';
cfg.keeptrials     = 'no'; 
cfg.trials         = 1:cut;
cfg.foi            = freqborder; %frequence of interest
cfg.toi            = timeborder;  
cfg.pad            = '1';
freq_del.p1        = ft_freqanalysis(cfg, pp_delay_correct.(['ch' num2str(ch)])) ;

cfg = [];
cfg.output         = 'pow';
cfg.method         = 'wavelet';
cfg.keeptrials     = 'no'; 
cfg.trials         = cut:(cut*2);
cfg.foi            = freqborder; %frequence of interest
cfg.toi            = 'all';    
cfg.pad            = '1';
freq_del.p2        = ft_freqanalysis(cfg, pp_delay_correct.(['ch' num2str(ch)])) ;

cfg = [];
cfg.output         = 'pow';
cfg.method         = 'wavelet';
cfg.keeptrials     = 'no'; 
cfg.trials         = (cut*2):(length(pp_delay_correct.(['ch' num2str(ch)]).trial));
cfg.foi            = freqborder; %frequence of interest
cfg.toi            = 'all';   
cfg.pad            = '1';
freq_del.p3        = ft_freqanalysis(cfg, pp_delay_correct.(['ch' num2str(ch)])) ;

x = nanmean(squeeze(freq_del.p1.powspctrm));%mean without NaN on reduced matrice (3D -> 2D)
C_mean_delay(:,1)= x;

x = nanmean(squeeze(freq_del.p2.powspctrm));
C_mean_delay(:,2)= x;

x = nanmean(squeeze(freq_del.p3.powspctrm));
C_mean_delay(:,3)= x;

C_mean_delay = rmmissing(C_mean_delay);%supp  NaN or empty cells 

%DELAY incorrect

cut = round(length(pp_delay_incorrect.(['ch' num2str(ch)]).trial)/3);

cfg = [];
cfg.output         = 'pow';
cfg.method         = 'wavelet';
cfg.keeptrials     = 'no'; 
cfg.trials         = 1:cut;
cfg.foi            = freqborder; %frequence of interest
cfg.toi            = 'all';  
cfg.pad            = '1';
Ifreq_del.p1        = ft_freqanalysis(cfg, pp_delay_incorrect.(['ch' num2str(ch)])) ;

cfg = [];
cfg.output         = 'pow';
cfg.method         = 'wavelet';
cfg.keeptrials     = 'no'; 
cfg.trials         = cut:(cut*2);
cfg.foi            = freqborder; %frequence of interest
cfg.toi            = 'all';   
cfg.pad            = '1';
Ifreq_del.p2        = ft_freqanalysis(cfg, pp_delay_incorrect.(['ch' num2str(ch)])) ;

cfg = [];
cfg.output         = 'pow';
cfg.method         = 'wavelet';
cfg.keeptrials     = 'no'; 
cfg.trials         = (cut*2):(length(pp_delay_incorrect.(['ch' num2str(ch)]).trial));
cfg.foi            = freqborder; %frequence of interest
cfg.toi            = 'all';  
cfg.pad            = '1';
Ifreq_del.p3        = ft_freqanalysis(cfg, pp_delay_incorrect.(['ch' num2str(ch)])) ;


x = nanmean(squeeze(Ifreq_del.p1.powspctrm));
I_mean_delay(:,1)= x;

x = nanmean(squeeze(Ifreq_del.p2.powspctrm));
I_mean_delay(:,2)= x;

x = nanmean(squeeze(Ifreq_del.p3.powspctrm));
I_mean_delay(:,3)= x;

I_mean_delay = rmmissing(I_mean_delay);%supp les NaN

% Table by bin 

Bin1(:,1) = C_mean_delay(:,1);
Bin1(:,2) = I_mean_delay(:,1);

Bin2(:,1) = C_mean_delay(:,2);
Bin2(:,2) = I_mean_delay(:,2);

Bin3(:,1) = C_mean_delay(:,3);
Bin3(:,2) = I_mean_delay(:,3);


%% Statistics table

clear  Value Bin Behav

%Create new formatted table 
Value = [C_mean_delay(:,1);C_mean_delay(:,2);C_mean_delay(:,3)];
Bin(1:length(C_mean_delay(:,1)),1) = 1;
Bin(1:length(C_mean_delay(:,2)),2) = 2;
Bin(1:length(C_mean_delay(:,3)),3) = 3;
Bin = [Bin(:,1);Bin(:,2);Bin(:,3)];
Behav(1:length(Value),1) = {'Correct'};

Correct = table(Value,Bin,Behav);

clear  Value Bin Behav

Value = [I_mean_delay(:,1);I_mean_delay(:,2);I_mean_delay(:,3)];
Bin(1:length(I_mean_delay(:,1)),1) = 1;
Bin(1:length(I_mean_delay(:,2)),2) = 2;
Bin(1:length(I_mean_delay(:,3)),3) = 3;
Bin = [Bin(:,1);Bin(:,2);Bin(:,3)];
Behav(1:length(Value),1) = {'Incorrect'};

Incorrect = table(Value,Bin,Behav);

All = [Correct;Incorrect];
varnames = {'Bin';'Behav'};

[p,tbl,stats] = anovan(All.Value,{All.Bin, All.Behav},2,3,varnames);%anova N-way

tbl(:,4) = [];%supp column 'singular?'

%post-hoc tests (multicomparison)
[results,~,~,gnames] = multcompare(stats,'Dimension',[1,2]);
tbl2 = array2table(results,"VariableNames",["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
tbl2.("Group A") = gnames(tbl2.("Group A"));
tbl2.("Group B") = gnames(tbl2.("Group B"));


%% %% Freq analysis on different trial types (pre-sample period)

%correct

cut = round(length(pp_presample_correct.(['ch' num2str(ch)]).trial)/3);

cfg = [];
cfg.output         = 'pow';
cfg.method         = 'wavelet';
cfg.keeptrials     = 'no'; 
cfg.trials         = 1:cut;
cfg.foi            = freqborder; %frequence of interest
cfg.toi            = 'all';  
cfg.pad            = '1';%car temps très court (0,5s)
freq_del2.p1        = ft_freqanalysis(cfg, pp_presample_correct.(['ch' num2str(ch)])) ;

cfg = [];
cfg.output         = 'pow';
cfg.method         = 'wavelet';
cfg.keeptrials     = 'no'; 
cfg.trials         = cut:(cut*2);
cfg.foi            = freqborder; %frequence of interest
cfg.toi            = 'all';  
cfg.pad            = '1';
freq_del2.p2        = ft_freqanalysis(cfg, pp_presample_correct.(['ch' num2str(ch)])) ;

cfg = [];
cfg.output         = 'pow';
cfg.method         = 'wavelet';
cfg.keeptrials     = 'no'; 
cfg.trials         = (cut*2):(length(pp_presample_correct.(['ch' num2str(ch)]).trial));
cfg.foi            = freqborder; %frequence of interest
cfg.toi            = 'all';   
cfg.pad            = '1';
freq_del2.p3        = ft_freqanalysis(cfg, pp_presample_correct.(['ch' num2str(ch)])) ;

%incorrect

cut = round(length(pp_presample_incorrect.(['ch' num2str(ch)]).trial)/3);

cfg = [];
cfg.output         = 'pow';
cfg.method         = 'wavelet';
cfg.keeptrials     = 'no'; 
cfg.trials         = 1:cut;
cfg.foi            = freqborder; %frequence of interest
cfg.toi            = 'all';    
cfg.pad            = '1';
Ifreq_del2.p1        = ft_freqanalysis(cfg, pp_presample_incorrect.(['ch' num2str(ch)])) ;

cfg = [];
cfg.output         = 'pow';
cfg.method         = 'wavelet';
cfg.keeptrials     = 'no'; 
cfg.trials         = cut:(cut*2);
cfg.foi            = freqborder; %frequence of interest
cfg.toi            = 'all';   
cfg.pad            = '1';
Ifreq_del2.p2        = ft_freqanalysis(cfg, pp_presample_incorrect.(['ch' num2str(ch)])) ;

cfg = [];
cfg.output         = 'pow';
cfg.method         = 'wavelet';
cfg.keeptrials     = 'no'; 
cfg.trials         = (cut*2):(length(pp_presample_incorrect.(['ch' num2str(ch)]).trial));
cfg.foi            = freqborder; %frequence of interest
cfg.toi            = 'all';   
cfg.pad            = '1';
Ifreq_del2.p3        = ft_freqanalysis(cfg, pp_presample_incorrect.(['ch' num2str(ch)])) ;

%% subplot with all figures

figure;
    ax1 = subplot(2,4,1:4);
        x = {Bin1, Bin2,Bin3};
        labels = {'Bin 1','Bin 2','Bin 3'};
        grpLabels = {'Correct','Incorrect'};
        h = boxplotGroup(x,'primaryLabels',labels,'SecondaryLabels',grpLabels,'GroupLabelType', 'Vertical','Colors','rkb', ...
            'GroupType','betweenGroups','groupLines',true);
        title(sprintf('Delay period %s - %s (%s)',FOI, monkey, date)); 
        ylabel('Puissance')
        ylim padded
        h.axis2.XAxis.FontSize = 12;
        h.axis2.XAxis.FontWeight = 'bold';
%         groups={[1,2],[4,5],[7,8]};
%         sigstar(groups,[0.001,0.001,0.001]);
%         groups={[1,4],[4,7]};
%         H=sigstar(groups,[0.001,0.001]);
%         set(H,'Color','b')
       %from table to figure (anova table)
       TString = evalc('disp(tbl)');
%      % Use TeX Markup for bold formatting and underscores.
       TString = strrep(TString,'<strong>','\bf');
       TString = strrep(TString,'</strong>','\rm');
       TString = strrep(TString,'_','\_');
%      % Get a fixed-width font.
       FixedWidth = get(0,'FixedWidthFontName');
       % Output the table using the annotation command.
       annotation(gcf,'Textbox','String',TString,'FitBoxToText','on','Interpreter','tex', ...
            'Margin',3,'HorizontalAlignment','center','VerticalAlignment','middle','Position',[0 0 1 1], 'FontName',FixedWidth);
    ax2 = subplot(2,4,5);
        plot(nanmean(squeeze(freq_del2.p1.powspctrm),2))
        title('Presample (correct)'); 
        hold on
        plot(nanmean(squeeze(freq_del2.p2.powspctrm),2))
        hold on 
        plot(nanmean(squeeze(freq_del2.p3.powspctrm),2))
        set(gca,'XTickLabel',freqborder)
        hold off
        ylabel('Puissance')
        xlabel('Fréquence (Hz)')
        legend('part 1','part 2','part 3')
    ax3 = subplot(2,4,6);
        plot(nanmean(squeeze(freq_del.p1.powspctrm),2))
        title('Delay (correct)'); 
        hold on
        plot(nanmean(squeeze(freq_del.p2.powspctrm),2))
        hold on 
        plot(nanmean(squeeze(freq_del.p3.powspctrm),2))
        set(gca,'XTickLabel',freqborder)
        hold off
        ylabel('Puissance')
        xlabel('Fréquence (Hz)')
        legend('part 1','part 2','part 3')
    ax5 = subplot(2,4,7);
        plot(nanmean(squeeze(Ifreq_del2.p1.powspctrm),2))
        title('Presample (incorrect)');
        hold on
        plot(nanmean(squeeze(Ifreq_del2.p2.powspctrm),2))
        hold on 
        plot(nanmean(squeeze(Ifreq_del2.p3.powspctrm),2))
        set(gca,'XTickLabel',freqborder)
        hold off
        ylabel('Puissance')
        xlabel('Fréquence (Hz)')
        legend('part 1','part 2','part 3')
    ax4 = subplot(2,4,8);
        plot(nanmean(squeeze(Ifreq_del.p1.powspctrm),2))
        title('Delay (Incorrect)'); 
        hold on
        plot(nanmean(squeeze(Ifreq_del.p2.powspctrm),2))
        hold on 
        plot(nanmean(squeeze(Ifreq_del.p3.powspctrm),2))
        set(gca,'XTickLabel',freqborder)
        hold off
        ylabel('Puissance')
        xlabel('Fréquence (Hz)')
        legend('part 1','part 2','part 3')
    linkaxes([ax2,ax3,ax4,ax5],'y');%link axes from diffrent plots

%% Save

%Save every figs
for k=1:length(h)
  saveas(h(k),sprintf('figure_%d.pdf',k))
end

%Save a global PDF
savepath = strcat('/Volumes/Procyk_Data_2/PhD_Marion/Gray analysis/',monkey,'/Ephys_data/',date,'/');
cd(savepath)
input_list = dir('*.pdf');
input_list = string({input_list.name})'; 
inputFiles = savepath+input_list;
outputFileName = string(strcat(monkey,'_',date,'_',area,'_figs.pdf'));
mergePdfs(inputFiles, outputFileName);

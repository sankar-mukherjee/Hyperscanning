clear; clc;
close all;

warning off;
addpath C:\Users\SMukherjee\Desktop\matlab_toolbox\fieldtrip-master
ft_defaults
%% ==================================================================================
% LOCAL PATHS
%==================================================================================
% to be edited according to calling PC local file system
os = system_dependent('getos');
if  strncmp(os,'Linux',2)
    project.paths.projects_data_root    = '/media/Data/sank/data';
    project.paths.svn_scripts_root      = '/home/sankar/Desktop/spic/dual_eng';
    project.paths.projects_root    = '/home/sankar/Desktop/spic';
    project.paths.toolbox.MSR          = '/home/sankar/Desktop/spic/matlab_toolbox/MSR_indentity/code';
    project.paths.toolbox.drtToolbox    = '/home/sankar/Desktop/spic/matlab_toolbox/drtoolbox';
    project.paths.toolbox.other    = '/home/sankar/Desktop/spic/matlab_toolbox/xxx';
else
    project.paths.projects_root    = 'C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\dual_eng';
    project.paths.projects_data_root    = 'C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data';
    project.paths.svn_scripts_root      = 'C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\dual_eng';
    project.paths.toolbox.MSR          = 'C:/Users/SMukherjee/Desktop/matlab_toolbox/MSR_indentity/code';
    project.paths.toolbox.drtToolbox    = 'C:/Users/SMukherjee/Desktop/matlab_toolbox/drtoolbox';
    project.paths.toolbox.other    = 'C:/Users/SMukherjee/Desktop/matlab_toolbox/xxx';
    project.paths.toolbox.Recurrence    = 'C:/Users/SMukherjee/Desktop/matlab_toolbox/crptool';    
end

%% Extra Paths
%%this need to change. insted of geo go to origial linux machine
project.paths.remote = '//geo.humanoids.iit.it/repository/groups/behaviour_lab/Projects/MNI/sankar/wordHTK/train';
% project.paths.remote = 'C:/Users/SMukherjee/Desktop/data/label_creation/phone_labels';


%% data
project.paths.wav = [project.paths.projects_data_root '/label_creation/wav'];
project.paths.text = [project.paths.projects_data_root '/label_creation/prompts'];
project.paths.phLabels = [project.paths.projects_data_root '/wordHTK/phone_labels'];
project.paths.processedData = [project.paths.projects_data_root '/dual_eng/mat'];
project.paths.figures = [project.paths.projects_data_root '/dual_eng/figures'];
% functions
project.paths.functions = [project.paths.svn_scripts_root '/functions'];
project.paths.functions_fieldtrip = [project.paths.svn_scripts_root '/functions/fieldtrip'];

% phoneHTK
project.paths.phoneHTK = [project.paths.projects_data_root '/phoneHTK'];
project.paths.result.phoneHTK = [project.paths.phoneHTK '/result/csv'];

project.paths.utility = [project.paths.projects_root '/utility'];
% add external matlab toolbox
addpath(project.paths.functions);
addpath(project.paths.functions_fieldtrip);

addpath(genpath(project.paths.toolbox.drtToolbox));
addpath(project.paths.toolbox.MSR);
addpath(project.paths.utility);
addpath(project.paths.toolbox.other);
% addpath(project.paths.toolbox.Recurrence);
%% ==================================================================================
% subject information
%==================================================================================
project.subjects.list = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16'};
project.session.list = {'_pre','_duet_1', '_duet_2', '_duet_3' ,'_duet_4','_post'};
project.session.duetList = [2 3 4 5];
project.subjects.group = {'A','B','C','D','E','F','G','H'};
project.subjects.gender = {'m','m','m','f','f','f','m','f'};
project.subjects.gender_comb = {'1(MM)','2(MM)','3(MM)','4(FF)','5(FF)','6(FF)','7(MM)','8(FF)'};

project.subjects.group_no = [1 2; 3 4; 5 6; 7 8; 9 10; 11 12; 13 14; 15 16];
project.subjects.partner = [2 1 4 3 6 5 8 7 10 9 12 11 14 13 16 15];

project.session.no = {'0', '1','2','3','4','5'};
project.subjects.male = [1 2 3 4 5 6 13 14];
project.subjects.female = [7 8 9 10 11 12 15 16];

project.subjects.data(1)  = struct('name', '01_riccardo'    , 'group', 'A', 'age', 24, 'gender', 'm', 'handedness', 'r', 'selfRate',[7 7 7 7],'otherLang', '', 'position', 1,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/01_riccardo_baseline_duet_raw_mc.set');
project.subjects.data(2)  = struct('name', '02_dino'        , 'group', 'A', 'age', 28, 'gender', 'm', 'handedness', 'r','selfRate',[7 6 6 6],'otherLang', '', 'position', 2,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/02_dino_baseline_duet_raw_mc.set');
project.subjects.data(3)  = struct('name', '03_luigi'       , 'group', 'B', 'age', 25, 'gender', 'm', 'handedness', 'r','selfRate',[6 6 7 6],'otherLang', '', 'position', 1,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/03_luigi_baseline_duet_raw_mc.set');
project.subjects.data(4)  = struct('name', '04_alessandro'  , 'group', 'B', 'age', 24, 'gender', 'm', 'handedness', 'r','selfRate',[7 7 7 6],'otherLang','', 'position', 2,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/04_alessandro_baseline_duet_raw_mc.set');
project.subjects.data(5)  = struct('name', '05_nicholas'    , 'group', 'C', 'age', 26, 'gender', 'm', 'handedness', 'r','selfRate',[9 7 9 8],'otherLang', '', 'position', 2,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/05_nicholas_baseline_duet_raw_mc.set');
project.subjects.data(6)  = struct('name', '06_garrlo'      , 'group', 'C', 'age', 24, 'gender', 'm', 'handedness', 'r','selfRate',[8 8 8 8],'otherLang', 'F', 'position', 1,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/06_garrlo_baseline_duet_raw_mc.set');
project.subjects.data(7)  = struct('name', '07_chiara'      , 'group', 'D', 'age', 28, 'gender', 'f', 'handedness', 'r','selfRate',[9 9 8 9],'otherLang', 'FS', 'position', 2,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/07_chiara_baseline_duet_raw_mc.set');
project.subjects.data(8)  = struct('name', '08_jessica'      , 'group', 'D', 'age', 25, 'gender', 'f', 'handedness', 'r','selfRate',[8 8 7 7],'otherLang', '', 'position', 1,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/08_jessica_baseline_duet_raw_mc.set');
project.subjects.data(9)  = struct('name', '09_alice'      , 'group', 'E', 'age', 25, 'gender', 'f', 'handedness', 'r','selfRate',[7 7 6 6],'otherLang', 'FSTC', 'position', 2,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/09_alice_baseline_duet_raw_mc.set');
project.subjects.data(10)  = struct('name', '10_mrium'      , 'group', 'E', 'age', 23, 'gender', 'f', 'handedness', 'r','selfRate',[10 6 7 7],'otherLang', 'FS', 'position', 1,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/10_mrium_baseline_duet_raw_mc.set');
project.subjects.data(11)  = struct('name', '11_anna'      , 'group', 'F', 'age', 28, 'gender', 'f', 'handedness', 'r','selfRate',[8 7 9 8],'otherLang', 'FS', 'position', 1,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/11_anna_baseline_duet_raw_mc.set');
project.subjects.data(12)  = struct('name', '12_sara'      , 'group', 'F', 'age', 26, 'gender', 'f', 'handedness', 'r','selfRate',[9 9 9 9],'otherLang', 'F', 'position', 2,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/12_sara_baseline_duet_raw_mc.set');
project.subjects.data(13)  = struct('name', '13_luca'      , 'group', 'G', 'age', 28, 'gender', 'm', 'handedness', 'l','selfRate',[9 8 9 8],'otherLang', '', 'position', 2,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/13_luca_baseline_duet_raw_mc.set');
project.subjects.data(14)  = struct('name', '14_fabio'      , 'group', 'G', 'age', 27, 'gender', 'm', 'handedness', 'r','selfRate',[8 8 8 8],'otherLang', 'F', 'position', 1,'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/14_fabio_baseline_duet_raw_mc.set');
project.subjects.data(15)  = struct('name', '15_valentina'      , 'group', 'H', 'age', 32, 'gender', 'f', 'handedness','r','selfRate',[7 7 7 5],'otherLang', 'F', 'position', 2, 'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/15_valentina_baseline_duet_raw_mc.set');
project.subjects.data(16)  = struct('name', '16_mariacarla'      , 'group', 'H', 'age', 29, 'gender', 'f', 'handedness','r','selfRate',[7 7 7 7],'otherLang', 'FS', 'position', 1, 'bad_ch', [],...
    'baseline_file','C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/04_mc/16_mariacarla_baseline_duet_raw_mc.set');


%% ============================= EEG ===============================

% paths
project.eeg.duet.O_path = 'C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/01_post_import/';
project.eeg.duet.F_path = 'C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/05_dual_removed/';
project.eeg.duet.other_path = 'C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/00_original_nocut_afterImport/';

project.eeg.solo_pre.O_path = 'C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/solo_pre/01_post_import/';
project.eeg.solo_pre.F_path = 'C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/solo_pre/04_mc/';
project.eeg.solo_post.O_path = 'C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/solo_post/01_post_import/';
project.eeg.solo_post.F_path = 'C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/solo_post/04_mc/';
project.eeg.solo_pre.other_path = 'C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/solo_pre/00_original_nocut_afterImport/';
%
% eeg markers
project.eeg.solo.speech.trial_Start = -1;
project.eeg.solo.speech.trial_End = 1;
project.eeg.solo.speech.condition_EEG_marker = {'21','22'};


project.eeg.duet.listen.trial_Start = -0.7;
project.eeg.duet.listen.trial_End = 0.7;
project.eeg.duet.speech.trial_Start = -0.7;
project.eeg.duet.speech.trial_End = 0.7;
project.eeg.duet.speech.condition_EEG_marker = {'41'};
project.eeg.duet.listen.condition_EEG_marker = {'42'};

project.eeg.duet.baselineS = 'b_start';
project.eeg.ERP_smoothWindow = 11;

%
project.eeg.configaration = {'project_structure_study_duet_speech','project_structure_study_duet_listen','project_structure_study_solo_speech'};

%
project.paths.backupICA                     = 'C:/Users/SMukherjee/Desktop/data/backup/After_ICA/EEG_clean/ica3';
project.paths.backupICA_baseline_initial    = 'C:/Users/SMukherjee/Desktop/data/backup/After_ICA/EEG_clean_duet_baseline/ica1';
project.paths.backupICA_baseline            = 'C:/Users/SMukherjee/Desktop/data/backup/After_ICA/EEG_clean_duet_baseline/ica2';
project.paths.backupICA_pre                 = 'C:/Users/SMukherjee/Desktop/data/backup/After_ICA/eeg_clean_pre/ica3';
project.paths.backupICA_post                = 'C:/Users/SMukherjee/Desktop/data/backup/After_ICA/eeg_clean_post/ica3';

%
project.eeg.channel_names={'F3','Fz','F4','C3','Cz','C4','P3','Pz','P4','Oz',...
    'C1','C2','C5','C6','T7','T8','FT7','FC5','FC3','FC1','FCz','FC2','FC4','FC6','FT8',...
    'F7','F5','F1','F2','F6','F8','AF7','AF3','AFz','AF4','AF8','Fp1','Fpz','Fp2','TP7',...
    'CP5','CP3','CP1','CPz','CP2','CP4','CP6','TP8','P9','P7','P5','P1','P2','P6','P8',...
    'P10','PO7','PO3','POz','PO4','PO8','O1','O2','Iz'};
% project.eeg.channel_names={'F3','Fz','F4'};
project.eeg.frequency_bands(1)=struct('name','teta','min',3,'max',7);
project.eeg.frequency_bands(2)=struct('name','mu','min',7.5,'max',13);
project.eeg.frequency_bands(3)=struct('name', 'beta1', 'min', 13.5, 'max', 17.5);
project.eeg.frequency_bands(4)=struct('name', 'beta2', 'min', 18, 'max', 22);

project.eeg.frequency_bands_list={};
for fb=1:length(project.eeg.frequency_bands)
    bands=[project.eeg.frequency_bands(fb).min, project.eeg.frequency_bands(fb).max];
    project.eeg.frequency_bands_list=[project.eeg.frequency_bands_list; {bands}];
end
project.eeg.frequency_bands_names={project.eeg.frequency_bands.name};


project.eeg.group_time_windows(1)=struct('name','-600 - -400'  ,'min',-600  , 'max',-400);
% project.eeg.group_time_windows(2)=struct('name','-400 - -200'  ,'min',-400  , 'max',-200);
project.eeg.group_time_windows(2)=struct('name','-600 - -200'  ,'min',-600  , 'max',-200);

project.eeg.group_time_windows(3)=struct('name','-200 - 0'  ,'min',-200  , 'max',0);
project.eeg.group_time_windows(4)=struct('name','0 - 200'  ,'min',0  , 'max',195);
project.eeg.group_time_windows_list={};
for fb=1:length(project.eeg.group_time_windows)
    bands=[project.eeg.group_time_windows(fb).min, project.eeg.group_time_windows(fb).max];
    project.eeg.group_time_windows_list=[project.eeg.group_time_windows_list; {bands}];
end

% ===================================================================================================
%% Phoneme List
project.vowel.list = {'aa','ae','ah','ao','aw','ax','ay','eh','er','ey','ih','iy','ow','oy','uh','uw'};
project.consonant.list = {'l','s','b','k','n','d','r','p','g','f','ng','t','m','hh','w','sh','ch','v','z','th','y'};
% vowel features
project.vowel.Front = {'iy','ih','eh'};
project.vowel.Central = {'eh','aa','er','ao'};
project.vowel.Back = {'uw','aa','ax','uh'};
project.vowel.High = {'ih','uw','aa','ax','iy'};
project.vowel.Medium = {'ey','er','aa','ax','eh','en','m','l','el'};
project.vowel.Low = {'eh','ay','aa','aw','ao','oy '};
project.vowel.Rounded = {'ao','uw','aa','ax','oy','w'};
project.vowel.Unrounded = {'eh','ih','aa','er','ay','ey','iy','aw','ah','ax','en','m','hh','l','el','r','y'};

% audio freq
project.fs = 44100;
%===============================control parameters=============================================
project.subjects_selected.list = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16'};

% formant 
project.preprocessing.formantexpected = 4;
project.preprocessing.formant_lpc_order = 10;   % 3 formants expected
project.preprocessing.formant_threshold = 1;

% loudness sharpness power
project.preprocessing.reference_L_S_P = 20;  %in Db

project.preprocessing.framelength = 0.01;   % 10 ms
project.preprocessing.frameshift = 0.005;   % 5 ms
project.preprocessing.melfilterbank = floor(3*log(project.fs));
project.preprocessing.MFCCdim = 12;     %(1+12)*3
project.preprocessing.mfccFeatwrapWin = 301;    %(that is 3 seconds at a typical 100 Hz frame rate).(need to check)
%% 
project.util.color = [0 1 0; 1 0 1; 0 1 1; 1 0 0; .2 .6 1; 1 .6 .2; 0 0 1; .6 .2 1; 1 1 0];
project.util.marker = {'o','+','*','.','x','s','d','^','v','>','<','p','h'}; 
project.util.marker = {'bo','r+','b*','y.','gx','ys','md','w^','rv','g>','k<','r*','ch','bx','c+','k.'}; 

%% GMM UBM
project.gmmUBM.gmmcomp = 32;
project.gmmUBM.MAPconfig = 'mwv';
project.gmmUBM.MAP_tau = 10;
project.gmmUBM.itaration = 10;

%% synchrony
project.synchrony.winLength = 8;
project.synchrony.winShift = 2;
project.synchrony.feature_name = {'F0';'F1';'F2';'Intensity';'reaction Time'};

project.synchrony.corr_threshold = 0.5;
project.synchrony.corr_sig = 0.05;
project.synchrony.maintain_uplimit = 0.1;
project.synchrony.maintain_downlimit = -0.1;

project.synchrony.feature_idx = [4 5 6 10];        % 'f0';'f1';'f2';'intensity';'reaction Time'

%% convergence
project.convergence.subA_conv_threshold = 0.2;
% project.convergence.subA_div_threshold = 1.5;
project.convergence.subB_conv_threshold = -0.2;
% project.convergence.subB_div_threshold = -1.5;
project.convergence.smoothWinLength = 7;  % to see the convergence trend (must be odd)
project.convergence.maintain_uplimit = 0.1;
project.convergence.maintain_downlimit = -0.1;

project.convergence.use_both_cond = 0;
project.convergence.fakestd   = 1.5;
%% ================================================ control Flow================================================
% =======================================================================================================================================================================
% =======================================================================================================================================================================
% =======================================================================================================================================================================
% =======================================================================================================================================================================
project.flag.createEEGData = 0;
project.flag.getSubjectReactionTime = 0;
project.flag.createTrainingData = 0 ;
project.flag.gmmUBM = 0;

project.flag.convergence =0;
project.flag.synchrony = 0;
project.flag.reactionTime = 0;

project.flag.mergeData = 0;

project.flag.findStates =0;

%% eeg
project.flag.EEG_createData  = 0;
project.flag.EEG_channelMeasures = 0;
% different analysis
project.flag.EEG_pre_duet_post  = 0;
project.flag.EEG_duet_listining  = 0;

project.flag.EEG  = 0;
project.flag.EEG_CCor  = 0;
project.flag.EEG_CCor_analysis  = 0;

%% EEG fieldtrip

project.flag.EEG_fieldtrip  = 0;
project.flag.excel_EEG_fieldtrip = 0;

%% perceptual test
project.flag.perceptual_test = 0;
% =======================================================================================================================================================================
% =======================================================================================================================================================================
% =======================================================================================================================================================================
% =======================================================================================================================================================================
%% =============================== Main ==============================================================
% get reactionTime
if(project.flag.getSubjectReactionTime)
    getSubjectReactionTime
end
% create and format data from raw data
if(project.flag.createTrainingData)
    createTrainingData_wordLevel(project);
end
% create EEG data from raw data
if(project.flag.createEEGData)
    mergeIndex_speech_EEG;
end

%% different modelling

% gmmUBM modelling
if(project.flag.gmmUBM)    
    gmmUBM_onlyGMM_directD(project);
%     gmm_configcheck(project)
end


if(project.flag.convergence)    
    convergence
end


%% EEG data

if(project.flag.EEG_fieldtrip)
    fieldTrip_cluster    
end
if(project.flag.excel_EEG_fieldtrip)
%     after_clustering   
    plot_different_fieldtripConfig_cluster
end

%% perceptual test
if(project.flag.perceptual_test)    
    select_pre_post_words_for_perceptual_test
end



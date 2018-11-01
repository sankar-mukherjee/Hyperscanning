
delta = [1 4];
theta = [4 8];
alpha = [8 12];
lowerBeta = [12 18];
higherBeta = [18 30];

%% speech plot
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\perfect\prespeech\importent_nobaseline_1sec_nolog_sepcond_oldsettings_5ms_-500-0\speech_tfr.mat',...
'GA_CONV','GA_NOCH');
time = [-0.5:0.5:0];location={'F5','F7','FT7','FC5'};
zlim = [-0.25 0.25];
figure;fieldtrip_topoPlot(GA_NOCH,delta,time,location,zlim);
figure;fieldtrip_topoPlot(GA_NOCH,theta,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,alpha,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,lowerBeta,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,higherBeta,time,location);

%% postlisten 
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\perfect\postlisten\importent_nobaseline_5ms_-500-0_0-500_oldsettings_listen_5sec_sepcond\listen_0-500.mat',...
'GA_CONV','GA_NOCH');
time = [0:0.5:0.5];location={'F5','F7','FC5'};


figure;fieldtrip_topoPlot(GA_NOCH,delta,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,theta,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,alpha,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,lowerBeta,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,higherBeta,time,location);

%% prelisten
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\-1to1EEG_config\1secRT\listen_-500-0.mat',...
'GA_CONV','GA_NOCH');
time = [-0.5:0.5:0];

location={'C4','C6','CP6','CP4'};

figure;fieldtrip_topoPlot(GA_NOCH,delta,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,theta,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,alpha,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,lowerBeta,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,higherBeta,time,location);


location={'POz','P2','P4','PO4'};

figure;fieldtrip_topoPlot(GA_NOCH,delta,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,theta,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,alpha,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,lowerBeta,time,location);
figure;fieldtrip_topoPlot(GA_NOCH,higherBeta,time,location);
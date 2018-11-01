%% speech data
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\perfect\10000it\EEG__32_10_mwv_mfc_convVSnoch_5ms_1.mat','data_conv','data_noCh');

%% cheking for cosistence subject
a = find(cellfun('isempty',data_conv));
b = find(cellfun('isempty',data_noCh));
a = [a; b];
a = unique(a);
data_conv2 = data_conv;
data_noCh2 = data_noCh;
data_conv2(a) = [];
data_noCh2(a) = [];

data_noCh2 = data_noCh2(1:length(data_conv2));
Nsub = length(data_conv2);

% trial no in both cond
a=[];b=[];
for i=1:Nsub
    a = [a size(data_conv2{i,1}.trial,2)];
    b = [b size(data_noCh2{i,1}.trial,2)];
end
sum(a)
sum(b)

cfg.method    = 'distance';
neighbours       = ft_prepare_neighbours(cfg, data_conv2{1});

% rereference
cfg = [];
cfg.reref       = 'yes';
cfg.channel = {'all'};
cfg.refchannel = {'all'};
for i = 1: length(data_conv2)
    data_conv2{i}        = ft_preprocessing(cfg,data_conv2{i});
    data_noCh2{i}        = ft_preprocessing(cfg,data_noCh2{i});
end

data_conv = data_conv2;data_noCh = data_noCh2;

save('speech_data.mat','data_conv','data_noCh');
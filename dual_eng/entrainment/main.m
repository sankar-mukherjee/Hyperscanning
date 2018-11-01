

clear
clc
load('listen_entrainment.mat');

freq_band = [1 4;4 8;8 12;12 18;24 36; 30 40];
f=2;

%% normalization
cfg           = [];
cfg.channel = data{1}.label(1:64);
cfg.demean                    = 'yes';
% cfg.detrend                    = 'yes';
cfg.bpfilter      = 'yes';
cfg.bpfreq        = freq_band(f,:);
cfg.hilbert    = 'complex';
% cfg.keeptrials = 'yes';

cfg_S = [];
cfg_S.channel = data{1}.label(65);
% cfg_S.demean                    = 'yes';
% cfg_S.detrend                    = 'yes';
cfg_S.lpfilter      = 'yes';
cfg_S.lpfreq        = 12;
cfg_S.hilbert    = 'complex';

new_data=[];
for i= 1:length(data)
   a = ft_preprocessing(cfg,data{i,1});
   b = ft_preprocessing(cfg_S,data{i,1});
    new_data{i,1} = ft_appenddata([], a, b);
end

%%
delay_samples = 1:10;
delays = delay_samples * 20; % ms
Ndel = length(delay_samples);
Nt = size(new_data{1,1}.trial{1,1},2);
Nch = 64;
Nperm = 100;

%% amp amp
MI_amp_amp =[];
for i= 1:length(data)
    A = new_data{i,1};
    Isig = zeros(length(A.trial),Nch,Ndel);
    
    for t=1:length(A.trial)
        eeg = real(A.trial{1,t}(1:Nch,:))';
        speech = real(A.trial{1,t}(65,:))';
        
        Iplnsum = zeros(Nch,Ndel);
        for di=1:Ndel
            d = delay_samples(di);
            for chi=1:Nch
                Iplnsum(chi,di) = gcmi_cc(eeg((1+d):end,chi), speech(1:(end-d)));
            end
        end
        
        Isig(t,:,:) = permutation_mi(Iplnsum,eeg,speech,delay_samples,Nch,Nt,Ndel,Nperm);     
        disp(t)
    end
    MI_amp_amp{i,1} = Isig;
end


%% amp phase
MI_amp_phase =[];
for i= 1:length(data)
    A = new_data{i,1};
    Isig = zeros(length(A.trial),Nch,Ndel);
    
    for t=1:length(A.trial)
        eeg = real(A.trial{1,t}(1:Nch,:))';
        
        speech = A.trial{1,t}(65,:)';
        a = sqrt(real(speech).^2 + imag(speech).^2);
        speech = cat(2,real(speech), imag(speech));        
        % normalise away amplitude so points lie on unit circle (direction only)
        speech = speech./[a a];
        speech = copnorm(speech);


        Iplnsum = zeros(Nch,Ndel);
        for di=1:Ndel
            d = delay_samples(di);
            for chi=1:Nch
                Iplnsum(chi,di) = gcmi_cc(eeg((1+d):end,chi), speech(1:(end-d),:));
            end
        end
        
        Isig(t,:,:) = permutation_mi(Iplnsum,eeg,speech,delay_samples,Nch,Nt,Ndel,Nperm);     
        disp(t)
    end
    MI_amp_phase{i,1} = Isig;
end


%% phase amp
MI_phase_amp =[];
for i= 1:length(data)
    A = new_data{i,1};
    Isig = zeros(length(A.trial),Nch,Ndel);
    
    for t=1:length(A.trial)
        eeg = (A.trial{1,t}(1:Nch,:))';
        a = sqrt(real(eeg).^2 + imag(eeg).^2);        
        eeg = cat(2, reshape(real(eeg),[Nt 1 Nch]), reshape(imag(eeg), [Nt 1 Nch]));
        eeg = bsxfun(@rdivide, eeg, reshape(a, [Nt 1 Nch]));        
        eeg = copnorm(eeg);

        speech = real(A.trial{1,t}(65,:))';

        Iplnsum = zeros(Nch,Ndel);
        for di=1:Ndel
            d = delay_samples(di);
            for chi=1:Nch
                Iplnsum(chi,di) = gcmi_cc(eeg((1+d):end,:,chi), speech(1:(end-d)));
            end
        end
        
        Isig(t,:,:) = permutation_mi(Iplnsum,eeg,speech,delay_samples,Nch,Nt,Ndel,Nperm);     
        disp(t)
    end
    MI_phase_amp{i,1} = Isig;
end


save('MI','MI_amp_amp','MI_amp_phase','MI_phase_amp');


%%
d=1;
for s=1:length(data)
    A =  squeeze(MI_amp_amp{s,1}(:,:,d));
    a = data{s,1}.trialinfo;
    conv = A(find(a),:);
    noch = A(find(a==0),:);
    
    A = [mean(conv); mean(noch)];
    
    for ch =1:64
       [h,p,ci,stats] = ttest2(conv(:,ch),noch(:,ch)); 
        
        
        
    end
end


ch = 3;
figure;
for ch=1:64
    for d=1:10
        a =  MI_amp_amp{1,1}(:,ch,d);
        plot(a);
        hold on
    end
end
a = squeeze(mean(MI_amp_amp{1,1},1));
b = squeeze(std(MI_amp_amp{1,1},1));

a = squeeze(MI_amp_amp{1,1}(:,:,5));


[A,B] = meshgrid(1:64,65);
i=cat(2,A',B');
a=reshape(i,[],2);
channelcmb = [ data{1,1}.label(a(:,1))' data{1,1}.label(a(:,2))'];

cfg           = [];
cfg.method    = 'mi';
cfg.channelcmb = channelcmb;
cfg.keeptrials = 'yes';
% cfg.covariance         = 'yes';
% cfg.removemean         = 'yes';

coh_full=[];
for i= 1:length(new_data)
    a = ft_timelockanalysis(cfg,new_data{i,1});
    coh_full{i,1} = ft_connectivityanalysis(cfg,a);
    
end

imagesc(squeeze())










plndat = new_data{1,1}.trial{1,1}(1:64,:);
fltspc = abs(new_data{1,1}.trial{1,1}(65,:));

[Nch, Nt] = size(plndat);

delay_samples = 1:17;
delays = delay_samples * 20; % ms
Ndel = length(delay_samples);

%% Calculate GCMI across all sensors and delays

% following the commonly used mass-univeriate approach we repeat 
% the calculation above for each sensor and delay
% we could call gcmi_cc as above inside the loop, but here we first
% normalise the data separately so we can reuse it for the permutation
% testing

% Gaussian-copula normalisation, works along first axis, applied to each 
% other dimension independently
cplnsum = abs(plndat)';
cspeech = (fltspc)';

Iplnsum = zeros(Nch,Ndel);
for di=1:Ndel
    d = delay_samples(di);
    % resize speech according to the lag/delay considered
    dspeech = cspeech(1:(end-d));
    for chi=1:Nch
        % as the data has been copula-normalised we can use the 
        % Gaussian parametric estimator (whatever the distribution was
        % originally)
        Iplnsum(chi,di) = mi_gg(cplnsum((1+d):end,chi), dspeech, true, true);
    end
end

figure
imagesc(delays,[],Iplnsum)
xlabel('MEG-Stimulus Delay (ms)')
ylabel('Channels')
title('Planar Gradient Amplitude')
colorbar

for i= 1:length(data)
    A = new_data{i,1};
    for t=1:length(A.trial)
        A = cat(3, A.trial{:});
        
        eeg = A(1:64,:,:);
        eeg = abs(permute(eeg, [3 2 1]));
        speech = squeeze(A(65,:,:))';
        
        eeg = abs(A.trial{1,t}(1:64,:))';
        speech = A.trial{1,t}(65,:)';
        
        Iplnsum = zeros(64,Ndel);
        for di=1:Ndel
            d = delay_samples(di);
            for chi=1:64
                Iplnsum(chi,di) = gcmi_cc(eeg(:,(1+d):end,chi), speech(:,1:(end-d)));
            end
        end
    end
end
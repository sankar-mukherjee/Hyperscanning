%% test to see if the real pair has singnificanct coherence than the fake ones using this paper
%{
Information flow between interacting human brains:Identification, validation, and relationship to social expertise

For the discovery sample, the reference distribution of nonpairs was created by 1,000 repetitions of the artificial sender/receiver pair assignments.
During each repetition, a random sample of 16 nonpairs (=^ 13 × 2 real pairs) was drawn from the distribution of permutated nonpairs, and lag estimation
was conducted as described above. For the replication sample, permutation
was repeated 10,000 times, and random samples of 50 nonpairs (=^ 25 ×
2 real pairs) were drawn. Next, the frequency of correlationNON-PAIRS >
correlationREAL PAIRS was determined (i.e., the ratio of (i) the number of cases
in which real pairs did not show higher neural coupling than nonpairs and
(ii) the number of total observations, i.e., 1,000 or 10,000). This frequency
represents the empirical P value testing whether neural coupling occurred
that is unique to real pairs. To determine the time window of neural
coupling, this procedure was repeated for every lag within the COI pair
until no significant difference of coupling indices between real pairs and

%}

fileList = dir([project.paths.processedData '/coherence/surrogate_coh_avgChannel/surrogate_coh*.mat']);


channel_no  = 4;


no_rep=length(fileList);
surrogate = zeros(no_rep,channel_no*channel_no,40,21);
for i=1:no_rep
   A = load([project.paths.processedData '/coherence/surrogate_coh_avgChannel/' fileList(i).name],'coh_surrogate'); 
   surrogate(i,:,:,:) = A.coh_surrogate.cohspctrm;
end
save([project.paths.processedData '/coherence/surrogate_coh_sig.mat'],'surrogate');

no_rep=1000;
load([project.paths.processedData '/coherence/surrogate_coh_sig.mat'])

%% real surrogate full subjectwise
load([project.paths.processedData '/coherence/coh_real_sig.mat'])
coh_prob = zeros(8,channel_no*channel_no,40,21);
for g=1:8
    real = coh_full{g}.cohspctrm;
    for ch=1:channel_no*channel_no
        for f=1:40
            for t=1:21
                A = squeeze(surrogate(:,ch,f,t));
%                 if(length(find(A>=real(ch,f,t))) == 0)
                    coh_prob(g,ch,f,t) = length(find(A>real(ch,f,t))) / no_rep;
%                 end
            end
        end
    end
end
save([project.paths.processedData '/coherence/coh_prob_real_surrogate_sig.mat'],'coh_prob');


%% real surrogate full whole
load([project.paths.processedData '/coherence/coh_real_sig.mat'])
a = strcat(coh_full{1,1}.labelcmb(:,1),coh_full{1,1}.labelcmb(:,2));
for g=1:8
    coh_full{g}.label = a;
    coh_full{g}.dimord = 'chan_freq_time';
end
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.keepindividual = 'no';
cfg.parameter = 'cohspctrm';
a = ft_freqgrandaverage(cfg, coh_full{:});

coh_prob = zeros(channel_no*channel_no,40,21);
real = a.cohspctrm;
for ch=1:channel_no*channel_no
    for f=1:40
        for t=1:21
            A = squeeze(surrogate(:,ch,f,t));
            %                 if(length(find(A>=real(ch,f,t))) == 0)
            coh_prob(ch,f,t) = length(find(A>real(ch,f,t))) / no_rep;
            %                 end
        end
    end
end
save([project.paths.processedData '/coherence/coh_prob_real_surrogate_sig_wholeEXP.mat'],'coh_prob');


%% convergence nochange
load([project.paths.processedData '/coherence/coherence_conv_noch.mat'])
coh_full = [];
coh_full{1,1}= coh_conv_group;
coh_full{2,1}= coh_no_group;


coh_prob = zeros(2,channel_no*channel_no,40,21);
for g=1:2
    real = coh_full{g}.cohspctrm;
    for ch=1:channel_no*channel_no
        for f=1:40
            for t=1:21
                A = squeeze(surrogate(:,ch,f,t));
                coh_prob(g,ch,f,t) = length(find(A>real(ch,f,t))) / no_rep;
            end
        end
    end    
end
save([project.paths.processedData '/coherence/coh_prob_real_surrogate_conv_noch_sig.mat'],'coh_prob');



    
    
    












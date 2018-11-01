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
project.paths.temppath = [project.paths.processedData '/coherence'];
fileList = dir([project.paths.processedData '/coherence/surrogate_coh/surrogate_coh*.mat']);
% fileList = dir([project.paths.processedData '/surrogate_coh*.mat']);

divider = 16;
channel_no = 64;
no_rep=length(fileList);

for comb=1:divider:channel_no*channel_no
    surrogate = zeros(no_rep,divider,40,21);
    parfor i=1:no_rep
        A = load([project.paths.temppath '/surrogate_coh/' fileList(i).name],'coh_surrogate');
        surrogate(i,:,:,:) = A.coh_surrogate.cohspctrm(comb:comb+divider-1,:,:);
    end
    save([project.paths.temppath '/surrogate_coh_ALL' num2str(comb) '.mat'],'surrogate');    
end


%% real surrogate full
load([project.paths.processedData '/coherence/coh_full.mat'])
coh_prob = zeros(8,channel_no*channel_no,40,21);

for comb=1:divider:channel_no*channel_no
    load([project.paths.temppath '/surrogate_coh_ALL' num2str(comb) '.mat'],'surrogate');    
    for g=1:8
        real = coh_full{g}.cohspctrm;
        channel = comb;
        for ch=1:divider
            for f=1:40
                for t=1:21
                    A = squeeze(surrogate(:,ch,f,t));
                    coh_prob(g,channel,f,t) = length(find(A>real(channel,f,t))) / no_rep;
                end
            end
            channel = channel + 1;
        end
    end    
end
save([project.paths.temppath '/coh_prob_real_surrogate.mat'],'coh_prob');


%% convergence nochange
load([project.paths.processedData '/coherence/coherence_conv_noch.mat'])
coh_full = [];
coh_full{1,1}= coh_conv_group;
coh_full{2,1}= coh_no_group;


coh_prob = zeros(2,channel_no*channel_no,40,21);

for comb=1:divider:channel_no*channel_no
    load([project.paths.temppath '/surrogate_coh_ALL' num2str(comb) '.mat'],'surrogate');
    for g=1:2
        real = coh_full{g}.cohspctrm;
        channel = comb;
        for ch=1:divider
            for f=1:40
                for t=1:21
                    A = squeeze(surrogate(:,ch,f,t));
                    coh_prob(g,channel,f,t) = length(find(A>real(channel,f,t))) / no_rep;
                end
            end
        end
        channel = channel + 1;
    end
end
save([project.paths.processedData '/coherence/coh_prob_real_surrogate_conv_noch.mat'],'coh_prob');




    
    











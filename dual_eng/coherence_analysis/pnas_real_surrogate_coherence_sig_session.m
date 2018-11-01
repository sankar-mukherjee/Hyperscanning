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



channel_no  = 4;session=4;
no_rep=1000;
load([project.paths.processedData '/coherence/surrogate_coh_sig.mat'])

%% real surrogate full
load([project.paths.processedData '/coherence/coh_real_sig_session.mat'])
coh_prob = zeros(8,session,channel_no*channel_no,40,21);
for g=1:8
    for session=1:4
        real = coh_full{g,session}.cohspctrm;
        for ch=1:channel_no*channel_no
            for f=1:40
                for t=1:21
                    A = squeeze(surrogate(:,ch,f,t));
                    %                 if(length(find(A>=real(ch,f,t))) == 0)
                    coh_prob(g,session,ch,f,t) = length(find(A>real(ch,f,t))) / no_rep;
                    %                 end
                end
            end
        end
    end
end
save([project.paths.processedData '/coherence/coh_prob_real_surrogate_sig_session.mat'],'coh_prob');


% 
% %% convergence nochange
% load([project.paths.processedData '/coherence/coherence_conv_noch.mat'])
% coh_full = [];
% coh_full{1,1}= coh_conv_group;
% coh_full{2,1}= coh_no_group;
% 
% 
% coh_prob = zeros(2,channel_no*channel_no,40,21);
% for g=1:2
%     real = coh_full{g}.cohspctrm;
%     for ch=1:channel_no*channel_no
%         for f=1:40
%             for t=1:21
%                 A = squeeze(surrogate(:,ch,f,t));
%                 coh_prob(g,ch,f,t) = length(find(A>real(ch,f,t))) / no_rep;
%             end
%         end
%     end    
% end
% save([project.paths.processedData '/coherence/coh_prob_real_surrogate_conv_noch_sig.mat'],'coh_prob');
% 
% 
% 
%     
    
    












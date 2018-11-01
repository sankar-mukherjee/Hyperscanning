function llr = score_gmm_trials_onlyGMM(models, testFiles, trials)
% computes the log-likelihood ratio of observations given the UBM and
% speaker-specific (MAP adapted) models. 
%
% Inputs:
%   - models      : a cell array containing the speaker specific GMMs 
%   - testFiles   : a cell array containing feature matrices or file names
%   - trials      : a two-dimensional array with model-test verification
%                   indices (e.g., (1,10) means model 1 against test 10)
%   - ubmFilename : file name of the UBM or a structure containing 
%					the UBM hyperparameters that is,
%					(ubm.mu: means, ubm.sigma: covariances, ubm.w: weights)
%
% Outputs:
%   - llr		  : log-likelihood ratios for all trials (one score per trial)
%
%
% Omid Sadjadi <s.omid.sadjadi@gmail.com>
% Microsoft Research, Conversational Systems Research Center

if ~iscell(models),
    error('Oops! models should be a cell array of structures!');
end



if iscellstr(testFiles),
    tlen = length(testFiles);
    tests = cell(tlen, 1);
    for ix = 1 : tlen,
        tests{ix} = htkread(testFiles{ix});
    end
elseif iscell(testFiles),
    tests = testFiles;
else
    error('Oops! testFiles should be a cell array!');
end

ntrials = size(trials, 1);

llr = zeros(ntrials, 1);
gmm1 = models{1,1};
gmm2 = models{2,1};
for tr = 1 : ntrials
    fea = tests{trials(tr, 2)};
    gmm1_llk = compute_llk(fea, gmm1.mu, gmm1.sigma, gmm1.w(:));
    gmm2_llk = compute_llk(fea, gmm2.mu, gmm2.sigma, gmm2.w(:));
    llr(tr) = mean(gmm1_llk - gmm2_llk);
end

function llk = compute_llk(data, mu, sigma, w)
% compute the posterior probability of mixtures for each frame
post = lgmmprob(data, mu, sigma, w);
llk  = logsumexp(post, 1);

function logprob = lgmmprob(data, mu, sigma, w)
% compute the log probability of observations given the GMM
ndim = size(data, 1);
C = sum(mu.*mu./sigma) + sum(log(sigma));
D = (1./sigma)' * (data .* data) - 2 * (mu./sigma)' * data  + ndim * log(2 * pi);
logprob = -0.5 * (bsxfun(@plus, C',  D));
logprob = bsxfun(@plus, logprob, log(w));

function y = logsumexp(x, dim)
% compute log(sum(exp(x),dim)) while avoiding numerical underflow
xmax = max(x, [], dim);
y    = xmax + log(sum(exp(bsxfun(@minus, x, xmax)), dim));
ind  = find(~isfinite(xmax));
if ~isempty(ind)
    y(ind) = xmax(ind);
end

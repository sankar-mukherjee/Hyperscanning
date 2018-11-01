function Isig=permutation_mi(Iplnsum,eeg,speech,delay_samples,Nch,Nt,Ndel,Nperm)


%% Permutation test for signifiance with the method of maximum statistics

% to account for the autocorrelation in both signals we implement the
% permutation with blocks of 10s
blocklen = 10 * 256; % block length in samples
Nblock = ceil(Nt / blocklen);

% seperate the copula-normalised data into 10s blocks
bplnsum = cell(1,Nblock);
bspeech = cell(1,Nblock);
blen = zeros(Nblock,1);
for bi=1:Nblock
    idx = block_index(bi,blocklen,Nt);
    bplnsum{bi} = eeg(idx,:);
    bspeech{bi} = speech(idx);
    blen(bi) = length(idx);
end

% fix a delay to make this example quicker (would usually repeat the
% calcualtion over all delays for each permutation)
Isig = zeros(64,Ndel);
for di=1:Ndel
    I = Iplnsum(:,di);
    d = delay_samples(di);
    
    Iperm = zeros(Nch,Nperm);
    for pi=1:Nperm
        thsperm = randperm(Nblock);
        % apply delay/lag shift to shuffled blocks
        [dmeg, dspeech] = block_delay(bplnsum, bspeech(thsperm), d);
        for chi=1:Nch
            Iperm(chi, pi) = gcmi_cc(dmeg(:,chi), dspeech);
        end
    end
    
    % method of maximum statistics
    % maximum values across permutations
    Imax = max(Iperm,[],1);
    thresh = prctile(Imax, 99);
    I(find(I<thresh))=0;
    Isig(:,di) = I;
end



end
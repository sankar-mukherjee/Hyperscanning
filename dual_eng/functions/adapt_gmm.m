function gmm = adapt_gmm(trainSpeakerData,nSpeakers,map_tau,config,ubm)

for s=1:nSpeakers
    gmm{s,1} = mapAdapt(trainSpeakerData(s, :), ubm, map_tau, config);
end


end
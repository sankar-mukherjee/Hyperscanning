function data = create_fieldtrip_trials(EEG)

tmpchanlocs  = EEG.chanlocs;
data.label   = { tmpchanlocs(1:EEG.nbchan).labels };
data.fsample = EEG.srate;

for index = 1:size(EEG.data,3)
    data.trial{index}  = EEG.data(:,:,index);
    %       data.time{index}   = linspace(EEG.xmin, EEG.xmax, EEG.pnts); % should be checked in FIELDTRIP
    data.time{index}   = EEG.times; % should be checked in FIELDTRIP
    data.trialinfo = EEG.trialinfo;
end

data.elec.pnt   = zeros(length( EEG.chanlocs ), 3);
for ind = 1:length( EEG.chanlocs )
    data.elec.label{ind} = EEG.chanlocs(ind).labels;
    if ~isempty(EEG.chanlocs(ind).X)
        data.elec.pnt(ind,1) = EEG.chanlocs(ind).X;
        data.elec.pnt(ind,2) = EEG.chanlocs(ind).Y;
        data.elec.pnt(ind,3) = EEG.chanlocs(ind).Z;
    else
        data.elec.pnt(ind,:) = [0 0 0];
    end
end

end
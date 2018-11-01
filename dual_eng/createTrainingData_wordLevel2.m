%%
% create train data for each word
% 1 subject no
% 2 session
% 3 word no
% 4 F0
% 5-9  formants (f1 f2 f3 f4 f5)
% 10 intensity
% 11 word duration
% 12 Loudness
% 13 sharpness
% 14 reaction time
% 15 word frequency form webclex corpus (cobS)

% ----------- this will be added after running conversation.m and save in convergence.mat
% 16 gmm score
% 17 mean fake gmm score
% 18 Convergence
% 19 divergence
% 20 convergence A
% 21 convergence B
% ----------- this will be added after running synchrony.m and save in synchrony.mat
% 22-23 F0 (synch asynch)
% 24-25 F1 (synch asynch)
% 26-27 F2 (synch asynch)
% 28-29 intensity (synch asynch)
%%
function D = createTrainingData_wordLevel2(project)

load('SPIC_text.mat');
load([project.paths.processedData '/reactionTime']);

i=1;
D = zeros(length(project.subjects.list)*4*50 + length(project.subjects.list)*2*40,14);
W = cell(length(project.subjects.list)*4*50 + length(project.subjects.list)*2*40,4);
mfc_full=[];
mfc=[];
mfc_raw=[];
mfc_full_raw = [];
fileList_name = [];
P = cell(length(project.subjects.list)*4*50 + length(project.subjects.list)*2*40,12);
for sub=1:length(project.subjects.list)

    for session = 1:6
        filelist = dir([project.paths.wav '/' project.subjects.list{sub} project.session.list{session} '-*.wav']);
        
        if(session == 1 || session == 6)
            word_length = 40;
        else
            word_length = 50;
        end
        
        %         for word = 1:length(filelist)
        for word = 1:word_length
            filename = [project.paths.wav '/' project.subjects.list{sub} ...
                project.session.list{session} '-' num2str(word.','%02d') '.wav'];
            
            text_filename = [project.paths.text '/' project.subjects.list{sub} project.session.list{session}];
            [id,words] = import_prompts(text_filename);
            index = ismember(id,['*/' project.subjects.list{sub} project.session.list{session} '-' num2str(word.','%02d')]);
            
%             if(sub == 1 || sub == 2 || sub == 3 || sub == 4)
%                 if(word <= length(filelist) )
%                     filename = [project.paths.wav '/' filelist(word).name];
%                     temp_f = strrep(filelist(word).name,'.wav','');
%                     index = ismember(id,['*/' temp_f]);
%                 else
%                     filename = [project.paths.wav '/xxx'];
%                 end
%                 %                 filelist(word) = [];
%             end
            
            if(exist(filename))
                [x,fs] = audioread(filename);
                
                index = find(index ==1);
                W{i,1} = words{index};
                
                index = ismember(SPIC_dict(:,1),words{index});
                index = find(index ==1);
                temp = SPIC_dict{index,3};
                
                W{i,3} = temp; % pronunciation
                W{i,4} = index;      % word index

                temp = strsplit(temp,' ');
                [aa,bb] = ismember(temp,project.vowel.list);
                bb(bb==0)=[];
                W{i,2} = bb;     % vowel index
                

                % word frequency
                D(i,15) = SPIC_dict{index,4};
                
                D(i,1) = sub;
                D(i,2) = session;
                D(i,3) = word;
                
                
                 %% using Praat
                data_len = floor(length(x) / fs * 1000 / 1);
                [F0, intensity, f1,f2,f3,f4,f5,bw1,bw2,bw3,bw4,bw5, err] = func_PraatPitch(filename, 0.005, 0, 75, 500, 0.03, 0.45, 0.01, 0.35, 0.14, 1, 1, 5, 1, 'cc', data_len);
                
                D(i,4) = mean(F0);
                % formant
                D(i,5:9) = [mean(f1) mean(f2) mean(f3) mean(f4) mean(f5)];
                % intensity
                D(i,10) = mean(intensity);
                % word duration
                D(i,11) = length(x)/fs;
                
                % keep all pitch
                P{i,1} = F0;
                P{i,2} = intensity;
                P{i,3} = f1;
                P{i,4} = f2;
                P{i,5} = f3;
                P{i,6} = f4;
                P{i,7} = f5;
                P{i,8} = bw1;
                P{i,9} = bw2;
                P{i,10} = bw3;
                P{i,11} = bw4;
                P{i,12} = bw5;

                %% reaction time
                wn = strrep(strrep(filename,[project.paths.wav '/' project.subjects.list{sub} project.session.list{session} '-'],''),'.wav','');
                wn = str2num(wn);
                
                if(session ~= 1 && session ~= 6)
                    A = cell2mat(subjectReactionTime{sub,session-1,1}(wn,2));
                    B = cell2mat(subjectReactionTime{sub,session-1,2}(wn,2));
                elseif(session == 1)
                    A = cell2mat(subjectReactionTime_pre{sub,1}(wn,2));
                    B = cell2mat(subjectReactionTime_pre{sub,2}(wn,2));
                elseif(session == 6)
                    A = cell2mat(subjectReactionTime_post{sub,1}(wn,2));
                    B = cell2mat(subjectReactionTime_post{sub,2}(wn,2));
                end
                D(i,14) = (A-B)/1e3;

                %%
                %                 [f,t,w] = enframe(x,project.preprocessing.framelength*fs,floor(project.preprocessing.frameshift*fs),'wm');        %use Hamming window
                [c,tc] = melcepst(x,fs,'0dD',project.preprocessing.MFCCdim,project.preprocessing.melfilterbank,project.preprocessing.framelength*fs,floor(project.preprocessing.frameshift*fs)); %see voicebox melep for full doc
                mfc{i,1} = fea_warping(c', project.preprocessing.mfccFeatwrapWin);     %(that is 3 seconds at a typical 100 Hz frame rate).(need to check)
                mfc_raw{i,1} = c';
                %                 if u want to compare the result befroe and after
                %                 hist(c(1,:), 30);                hist(mfc(1,:), 30);
                %                 hist(fea_warping(c(2,:), 301), 30)
                %                 hist(wcmvn(c(2,:), 301, true), 30)  %local (not useful here)
                %                 hist(cmvn(c(2,:), true), 30)        %global (not useful here)
                %% adding extra prosodic feature to mfcc
                a = floor(tc/fs *1000);
                a = [0;a];
                a=[a [a(2:end);size(F0,2)]];                
                a(:,1) = a(:,1)+1;                
                
                extra_feat = zeros(length(a),4);
                
                if(length(f1)==1)
                    f1=zeros(1,length(F0));
                    f2=zeros(1,length(F0));
                end
                                    
                for ex=1:length(a)
                    extra_feat(ex,:) = [nanmean(F0(a(ex,1):a(ex,2))) nanmean(f1(a(ex,1):a(ex,2))) nanmean(f2(a(ex,1):a(ex,2))) nanmean(intensity(a(ex,1):a(ex,2)))];%only 4
                end
                EX = [c extra_feat(1:end-1,:)];
                mfc_full_raw{i,1} = EX';
                mfc_full{i,1} = fea_warping(EX', project.preprocessing.mfccFeatwrapWin);     %(that is 3 seconds at a typical 100 Hz frame rate).(need to check)
                
                
                
                
           
                fileList_name{i,1} = strrep(filename,[project.paths.wav '/'],'');
            else
                
            end
            disp([project.subjects.list{sub} '-' num2str(session) '-' num2str(D(i,3)) '-' num2str(i)]);
            i=i+1;
        end
    end
end
save([project.paths.processedData '/processed_data_word_level2.mat'],'D','W','mfc','mfc_raw','mfc_full','mfc_full_raw','P','fileList_name');

end
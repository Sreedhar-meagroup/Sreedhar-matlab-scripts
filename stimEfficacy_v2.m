rawText = fileread('130619_4205_stimEfficacy.log');
[dummy,~, newLinePos] = regexp(rawText,'\n','match');
%% stimAmp_V
stimAmp_pattern = 'Stimulus amplitude \(V\) : (\d*\.*\d*)';
stimAmp_str = regexp(rawText,stimAmp_pattern,'tokens');
stimAmpV = str2double(stimAmp_str{1});


%% pulseWidth_musec
pulseWidth_pattern = 'Pulse width\D+(\d+)';
pulseWidth_str = regexp(rawText,pulseWidth_pattern,'tokens');
pulseWidth_musec = str2double(pulseWidth_str{1});

%% nPulses
nPulses_pattern = 'nr_pulses\D+(\d+)';
nPulses_str = regexp(rawText,nPulses_pattern,'tokens');
nPulses = str2double(nPulses_str{1});

%% nPackages

nPackages_pattern = 'nr packages\D+(\d+)';
nPackages_str = regexp(rawText,nPackages_pattern,'tokens');
nPackages = str2double(nPackages_str{1});

%% nStimEl
nStimEl_pattern = 'No. of stimulation electrodes\D+(\d+)';
[nStimEl_str,pos] = regexp(rawText,nStimEl_pattern,'tokens');
nStimEl = str2double(nStimEl_str{1});
newLinesLeft = newLinePos(pos<newLinePos);
%% StimEl (cr)
stimEl_raw = rawText(newLinesLeft(1):newLinesLeft(2));
stimEl_pattern = '\d\d';
stimEl_str = regexp(stimEl_raw,stimEl_pattern,'match');
for ii = 1:size(stimEl_str,2)
    stimEl(ii) = str2num(stimEl_str{ii});
end


%%%%%%%%%%%%% HIER BITTE %%%%%%%%%%%%%%%%%%%%%%

pattern1 = 'result of stimulus efficacy estimation:';
[sent1, start1, end1]=regexp(rawText,pattern1,'match');
text2 = rawText(end1+1:end);
pattern2 = 'Sum over all recording sites for stim site (\d\d): ([\d]+)';
[sent2 start2 end2 token2Indices token2Content] = regexp(text2, pattern2, 'match');
numStimSites = size(sent2,2);
stimSites = cell2mat(cellfun(@(c) c(1), token2Content)');
sumOfSpikes = cell2mat(cellfun(@(c) c(2), token2Content)');
%do this for each stim site
for ii = 1: numStimSites
    if ii == 1
        text3 = text2(1:start2(1)-1);
    else
        text3 = text2(end2(ii-1)+1:start2(ii)-1);
    end
pattern3 = '([\d]+)\s';
[sent3 start3 end3 token3Indices token3Content] = regexp(text3, pattern3, 'match');
NumSpikes{ii} = token3Content;
end

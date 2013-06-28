rawText = fileread('130311_4106_choiceof_stim_el.txt');
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

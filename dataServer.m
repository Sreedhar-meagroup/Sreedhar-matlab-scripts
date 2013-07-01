% datRoot = {'130308_4106','130311_4105','130311_4106','130311_4108',...
%            '130312_4096','130313_4104','130313_4107','130313_4109',...
%            '130313_4120','130322_4115','130322_4121','130322_4124'};


% create a reg exp solution to the filename problem.

datRoot = {%'130610_4205','130610_4217','130613_4239','130614_4224',...
           %'130614_4237','130617_4222',...
           '130628_4243'};
maxT = 30; % window for correlogram in ms
NBS_res = cell(size(datRoot,2),2);
%run this part whenever you have new spontaneous recordings
for count = 1:size(datRoot,2)
    createNBSMat(datRoot{count});
    %createCFPMat(datRoot{count},maxT);
    [NBS_res{count,1}, NBS_res{count,2}] = createFigs(datRoot{count},'NBS');
end
% run this part when you need figures from the mat files
% for count = 1:size(datRoot,2)
%     createFigs(datRoot{count},'NBS','CFP',maxT);
% end

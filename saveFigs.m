function saveFigs(context, datRoot, handles, stimSites)
% to be generalized later
switch context
    case 'stimAnalysis'
        thisDirectory = mfilename('fullpath');
        thisDirectory=thisDirectory(1:find(thisDirectory=='\',1,'last'));
        [~, name] = system('hostname');
        if strcmpi(strtrim(name),'sree-pc')
            fPath = 'D:\Codes\Lat_work\Closed_loop\StimRespAnalysis\';
        elseif strcmpi(strtrim(name),'petunia')
            fPath = 'C:\Sreedhar\Lat_work\Closed_loop\StimRespAnalysis\';
        end
        cd(fPath);
        if exist(datRoot,'dir') ~= 7
            mkdir(datRoot);
        end
            fPath = [fPath,datRoot,'\'];
        cd(thisDirectory);
        
        saveas(handles(1), fullfile(fPath,[datRoot,'_GFR_rstr']), 'fig');
        %saveas(handles(2), fullfile(fPath,[datRoot,'_raster']), 'fig');
        
        for ii = 1:5
            set(handles(ii+1),'PaperPositionMode','auto'); 
            set(handles(ii+1),'PaperOrientation','landscape');
            set(handles(ii+1),'Position',[50 50 1200 800]);
            print(handles(ii+1), '-depsc', [fPath,datRoot,'_',num2str(stimSites(ii)+1),'.eps']); % hw+1
        end     
end
        
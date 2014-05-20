figPath = 'C:\Sreedhar\Lat_work\NetControl\NetControl_data_analysis\NetControlDataAnalysis\figures\'; % to be modified
% figPath = 'C:\Users\duarte\Desktop\temp_figs\test\';
figNameTemplate = [figPath,CID,'_','s',session_number,'_'];
proceed_flag = 0;

if exist([figNameTemplate,'rlvsstimno.eps'],'file')
    choice = questdlg('Would you like to replace all figs?', ...
	'Files exist!', ...
	'Yes','No','Yes');
    % Handle response
    if strcmpi(choice,'yes')
        proceed_flag = 1;
    end
else
    choice = questdlg('Would you like to save all 20 figs?', ...
	figNameTemplate(end-7:end-1), ...
	'Yes','No','Yes');
    if strcmpi(choice,'yes')
        proceed_flag = 1;
    end
end

if proceed_flag
    saveas(rlvsstimno_h,[figNameTemplate,'rlvsstimno.eps'], 'psc2');
    saveas(silvsstimno_h,[figNameTemplate,'silvsstimno.eps'], 'psc2');
    saveas(rlvssil_h,[figNameTemplate,'rlvssil.eps'], 'psc2');
    
    saveas(IBI_pre_h,[figNameTemplate,'IBI_pre.eps'], 'psc2');
    saveas(IBI_post_h,[figNameTemplate,'IBI_post.eps'], 'psc2');
    
    saveas(respdist_h,[figNameTemplate,'respdist.eps'], 'psc2');
    
    saveas(IBI_rec_pre_h,[figNameTemplate,'IBI_rec_pre.eps'], 'psc2');
    saveas(IBI_rec_post_h,[figNameTemplate,'IBI_rec_post.eps'], 'psc2');   
    saveas(ISI_rec_pre_h,[figNameTemplate,'ISI_rec_pre.eps'], 'psc2');
    saveas(ISI_rec_post_h,[figNameTemplate,'ISI_rec_post.eps'], 'psc2');
    saveas(nSp_diffcases_h,[figNameTemplate,'nSp_diffcases.eps'], 'psc2');
    saveas(spon_dist_h,[figNameTemplate,'spon_dist.eps'], 'psc2');
    
    for ii = 1:length(qtab_h)
        saveas(qtab_h(ii),[figNameTemplate,'qtab-',num2str(ii),'.eps'],'psc2');
    end
    
    saveas(IstimI_dist_h,[figNameTemplate,'IstimI_dist.eps'], 'psc2');
    saveas(IstimI_evol_h,[figNameTemplate,'IstimI_evol.eps'], 'psc2');
    saveas(stimfreqvstime_h,[figNameTemplate,'stimfreqvstime.eps'], 'psc2');
    
    saveas(trials_all_h,[figNameTemplate,'trials_all.eps'], 'psc2');
    saveas(errvslpb_h,[figNameTemplate,'errvslpb.eps'], 'psc2');
    
else
    disp('Message:: No figures were saved.');
end

disp('Message:: Figures were SUCCESSFULLY saved.');



%HW channels (1-60)
function varargout = createFigs(datRoot,varargin)
% createFigs is useful for three figure rendering tasks.
% 1. createFigs(datRoot,'NBS') -- creates a histogram of the network burst
% starts :)
% 2. createFigs(datRoot,'CFP', maxT) -- creates a correlogram of the
% spontaneous activity
% 3. createFigs(datRoot,'NBS','CFP', maxT) -- creates a histogram as in (1),
% a correlogram as in (2), and overlays a column-wise sum in (1) as well.
% varargout is a cell array of the filename and the stimchanneles in RC
% format.
if nargin > 1
    nr_inputs = nargin;
        switch nr_inputs
            case 2
                task = varargin{1};
            case 3
                 task = varargin{1};
                 maxT = varargin{2};
            case 4
                 task = 'both';
                 maxT = varargin{3};
            otherwise
                disp('Please check your inputs!!!')
        end
end
    
fpath = 'C:\Sreedhar\Lat_work\Closed_loop\NBS_CFP_figs\';
    
    if strcmp(task,'NBS') || strcmp(task,'both')
        dat_NBS = [datRoot,'_NBS.mat'];
        load(dat_NBS);
        figure(1)
        bar(EL_array,nr_starts(sort_ind))
        set(gca,'XTick',1:length(sort_ind),'xtickLabel',num2str(active_EL(EL_array(sort_ind))'+1));
        xlabel(' electrode' )
        ylabel(' Nr. of NB starts' );
        title(['total of ', num2str(nr_NB),' NBs detected (hw+1)'])
        saveas(gcf, fullfile(fpath,[datRoot,'_NBS']), 'epsc');
        varargout{1} = datRoot; varargout{2} = hw2cr(active_EL(EL_array(sort_ind)));
    end
   if strcmp(task,'CFP') || strcmp(task,'both')
       load([datRoot,'_CFP_',num2str(maxT),'ms.mat']);
        figure(2)
        imagesc(cfprobability), axis square,  colorbar
        saveas(gcf, fullfile(fpath, [datRoot,'_CFP_',num2str(maxT),'ms']), 'epsc');
   end
   if strcmp(task,'both')
        figure(1)
        [sum_cfp, idx_cfp] = sort(sum(cfprobability),'descend');
        firstTen = sum_cfp(1:10);
        firstTen_norm = firstTen*nr_starts(sort_ind(1))/firstTen(1);
        hold on
        plot(firstTen_norm,'.-r', 'LineWidth',2,'MarkerSize',18);
        hold off
        saveas(gcf, fullfile(fpath,[datRoot,'_both']), 'epsc');
    end
    close all
end
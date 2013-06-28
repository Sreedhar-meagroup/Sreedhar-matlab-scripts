%function mea_88_color_electrode

function mea_88_color_electrode(axis_handle,MEA_electrode,el_color,varargin);


el_color_face = el_color;
el_color_edge = el_color;

markersize = 15;
linewidth = 0.5;



%with pvpmod and vararginm  can define other colors for face and edge
if ~isempty(varargin)
    pvpmod(varargin)
end



axis(axis_handle);
hold on
col_pos = floor(MEA_electrode/10);
row_pos = 8 - (MEA_electrode-col_pos*10) +1 
plot(col_pos,row_pos,'o','markersize',markersize,'markerfacecolor',el_color_face,'markeredgecolor',el_color_edge','linewidth', linewidth);

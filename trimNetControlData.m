function NetControlData_trim = trimNetControlData(NetControlData)

NetControlData_trim = NetControlData;
if ~isempty(NetControlData_trim.Spikes)
    fnames = fieldnames(NetControlData_trim.Spikes);
    for ii = 1:length(fnames)
        if strcmpi(fnames{ii},'time') || strcmpi(fnames{ii},'channel')
            continue;
        else
            NetControlData_trim.Spikes = rmfield(NetControlData_trim.Spikes,fnames{ii});
        end
    end
end

try
if ~isempty(NetControlData_trim.Pre_spontaneous)
    fnames = fieldnames(NetControlData_trim.Pre_spontaneous.Spikes);
    for ii = 1:length(fnames)
        if strcmpi(fnames{ii},'time') || strcmpi(fnames{ii},'channel')
            continue;
        else
            NetControlData_trim.Pre_spontaneous.Spikes = rmfield(NetControlData_trim.Pre_spontaneous.Spikes,fnames{ii});
        end
    end
end


if ~isempty(NetControlData_trim.Post_spontaneous)
    fnames = fieldnames(NetControlData_trim.Post_spontaneous.Spikes);
    for ii = 1:length(fnames)
        if strcmpi(fnames{ii},'time') || strcmpi(fnames{ii},'channel')
            continue;
        else
            NetControlData_trim.Post_spontaneous.Spikes = rmfield(NetControlData_trim.Pre_spontaneous.Spikes,fnames{ii});
        end
    end
end
end
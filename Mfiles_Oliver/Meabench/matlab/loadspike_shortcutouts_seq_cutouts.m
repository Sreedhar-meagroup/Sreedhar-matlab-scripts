%This function load a sequence of spikes from datasets with short cutouts (prior to oct
%2006). This is useful in order to be able to read context from large
%datafiles. I have a similar implementation for datasets with long cutouts
%as well.

function y=loadspike_shortcutouts_seq_cutouts(fn,range,freq,spike_beg,spike_end)

MAX_SPIKE_IMPORT=200000;

if nargin < 5
    error('wrong number of arguments');
end


num_spikes = (spike_end - spike_beg) + 1;
if num_spikes  > MAX_SPIKE_IMPORT
    error('too many spikes to import, max number should not exceed %d spikes',MAX_SPIKE_IMPORT)
else 
    sprintf('reading %d spikes ',num_spikes);
end

fid = fopen(fn,'rb');
if (fid<0)
  error('Cannot open the specified file');
end


spike_beg_byte  = (spike_beg-1)*264;
spike_end_byte  =  spike_end*264-1;

ret_val = fseek(fid,spike_beg_byte,-1);   %set the file position to the beginning of the 1st spike to store
if ret_val==-1
    error(' setting file position failed, returning without calculation' )
    return
end



raw = fread(fid,[82 num_spikes],'int16');     %fills an 82xinum_spikes matrix, , 
                                       
                                       %'int16' is a data type specifier,
                                       %i.e. int with a size of 16 bits
                                       %(2byte)
fclose(fid);
ti0 = raw(1,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
ti1 = raw(2,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
ti2 = raw(3,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
ti3 = raw(4,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
y.time = (ti0 + 65536*(ti1 + 65536*(ti2 + 65536*ti3)));
y.channel = raw(5,:);
y.height = raw(6,:);
y.width = raw(7,:);
y.context = raw(8:81,:);
y.thresh = raw(82,:);

%the following part is for the case when a gain argument is given
if ~isnan(range)
  if ~isempty(find([0 1 2 3]==range))
    ranges= [ 3410,1205,683,341 ];
    range = ranges(range+1);
    auxrange = range*1.2;
    %if isnan(freq)
     % freq = 25.0;
    %end
    isaux = find(y.channel>=60);
    iselc = find(y.channel<60);
    y.height(iselc) = y.height(iselc) .* range/2048;
    y.thresh(iselc) = y.thresh(iselc) .* range/2048;
    y.context(:,iselc) = y.context(:,iselc) .* range/2048;
    %add the following because initially spikecontext values were always
    %relativ to digital 0
    y.context          = y.context-range;
    y.height(isaux) = y.height(isaux) .* auxrange/2048;
    y.thresh(isaux) = y.thresh(isaux) .* auxrange/2048;
    y.context(:,isaux) = y.context(:,isaux) .* auxrange/2048;
  else
    y.height = y.height  .* range/2048;
    y.thresh = y.thresh  .* range/2048;
    y.context= y.context .* range/2048;
  end
end    


%this is the part where it imports data without any conversion of the time
%or voltage, i.em when no argument is given
if ~isnan(freq)
  y.time = y.time ./ (freq*1000);
  y.width = y.width ./ freq;
end

%delete the (mostly) unused fields 'width','height' and 'thresh'
y = rmfield(y,'height');
y = rmfield(y,'width');
y = rmfield(y,'thresh');


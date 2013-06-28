%
%file loadspike_seq_cutouts
%11/12/06
%this file reads a sequence of cutouts froma large spike file where it is
%not possible to import all the data
%
%25/04/07
%as input the (sequential) spike nr. as they appear during recording
%has to be given for the first and last spike with cutouts to be loaded into the workspace
%
%function y=loadspike_seq_cutouts(fn,range,freq,spike_beg,spike_end);


function y=loadspike_seq_cutouts(fn,range,freq,spike_beg,spike_end);
%loadspike_seq_cutouts loads sequential spike data from file fn into a
%structure y. the sequence of spikes is from spike_beg to spike_end,
%the total length of stored spike sshould not exceed a certain limit,
%otherwise there are memory errors
%members of y:
%   time    (1xN) 
%   channel (1xN)
%   height  (1xN)
%   width   (1xN)
%   context (132xN)
%   thresh  (1xN)

%a cutout is stored as a 132-long vector, each value in this vector is a
%2-byte value, i.e. each spike has 264 bytes


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


%read from the file and store it in the structure
raw = fread(fid,[132 num_spikes],'int16');     %fills an 132xnum_spikes matrix, w
                                       
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
y.context = raw(8:131,:);
y.thresh = raw(132,:);

%the following part is for the case when a gain argument is given
if ~isnan(range)
  if ~isempty(find([0 1 2 3]==range))
    ranges= [ 3410,1205,683,341 ];
    range = ranges(range+1);
    auxrange = range*1.2;
 
    isaux              = find(y.channel>=60);
    iselc              = find(y.channel<60);
    y.height(iselc)    = y.height(iselc) .* range/2048;
    y.thresh(iselc)    = y.thresh(iselc) .* range/2048;
    y.context(:,iselc) = y.context(:,iselc) .* range/2048;
    %add the following because initially spikecontext values were always
    %relativ to digital 0
    y.context          = y.context-range;
    y.height(isaux)    = y.height(isaux) .* auxrange/2048;
    y.thresh(isaux)    = y.thresh(isaux) .* auxrange/2048;
    y.context(:,isaux) = y.context(:,isaux) .* auxrange/2048;
  else
    y.height = y.height  .* range/2048;
    y.thresh = y.thresh  .* range/2048;
    y.context= y.context .* range/2048;
  end
end    

if ~isnan(freq)
  y.time = y.time ./ (freq*1000);
  y.width = y.width ./ freq;
end



%delete the (mostly) unused fields 'width','height' and 'thresh'
y = rmfield(y,'height');
y = rmfield(y,'width');
y = rmfield(y,'thresh');




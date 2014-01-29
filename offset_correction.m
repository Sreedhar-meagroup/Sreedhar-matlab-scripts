function offset_corrected = offset_correction(contexts)
  first = contexts(1:15,:);
  last  = contexts(110:end,:);
  dc1   = mean(first);
  dc2   = mean(last);
  v1    = var(first);
  v2    = var(last);
  dc    = (dc1.*v2+dc2.*v1)./(v1+v2+1e-10); % == (dc1/v1 + dc2/v1) / (1/v1 + 1/v2)
  offset_corrected = contexts - repmat(dc,124,1);
end
    

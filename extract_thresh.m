function [thresh] = extract_thresh(filepath)
% extract_thresh('filename') extracts the spike detection threshold from
% the .desc file accompanying the data (see MeaBench recording format).

    str = fileread(filepath);
    expr = '\s*Threshold:\s*.*?\s*\d+\s*';
    fstr = regexp(str,expr,'match');
    fexpr = '(\s*\d+\s*)';
    [~, tok] = regexp(fstr, fexpr, 'match', 'tokens');
    thresh = str2double(cell2mat(strtrim(tok{1}{1})));
function [thresh] = extract_thresh(filepath)
    str = fileread(filepath);
    expr = '\s*Threshold:\s*.*?\s*\d+\s*';
    fstr = regexp(str,expr,'match');
    fexpr = '(\s*\d+\s*)';
    [mat tok] = regexp(fstr, fexpr, 'match', 'tokens');
    thresh = str2double(cell2mat(strtrim(tok{1}{1})));
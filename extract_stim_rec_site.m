function [stimSite , recSite] = extract_stim_rec_site(filepath)

    str = fileread(filepath);
    expr = '\w*\s*Stimulating:\s*\w*\s*.*?\s*\d+\s*:\s*\d+\s*';
    fstr = regexp(str,expr,'match');
    fexpr = '(\s*\d+\s*)';
    [mat tok] = regexp(fstr, fexpr, 'match', 'tokens');
    stimSite = str2double(cell2mat(strtrim(tok{1}{1})));
    recSite = str2double(cell2mat(strtrim(tok{1}{2})));

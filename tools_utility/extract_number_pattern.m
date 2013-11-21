str = fileread('E:/Sample/session_1_4350.log');
expr = '\w*\s*Stimulating:\s*\w*\s*.*?\s*\d+\s*:\s*\d+\s*';
fstr = regexp(str,expr,'match');
fexpr = '(\s*\d+\s*)';
[mat tok] = regexp(fstr, fexpr, 'match', 'tokens');
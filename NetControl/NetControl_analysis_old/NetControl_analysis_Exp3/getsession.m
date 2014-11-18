function session_no = getsession(pathName)
pos = strfind(pathName,'session');
session_no = pathName(pos(1)+8);
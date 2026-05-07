function vr = getFixHvalues(vr)

    prompt = {'First h value:', 'Second h value:'};
    dlgtitle = 'Input Fixed Heading Values';
    dims = [1 35];
    definput = {'0', ''};
    
    hinfo = inputdlg(prompt, dlgtitle, dims, definput);
    vr.fixHvalues = [str2num(hinfo{1}) str2num(hinfo{2})];
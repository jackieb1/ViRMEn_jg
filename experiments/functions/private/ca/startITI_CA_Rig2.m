function vr = startITI_CA_Rig2(vr)

vr.itiStartTime = tic;
vr.inITI = 1;

vr.worlds{vr.currentWorld}.surface.visible(:) = 0; % make surface of world invisible
vr.worlds{vr.currentWorld}.backgroundColor = [0.69 0.69 0.69]; % set ITI color to specific grey value

end
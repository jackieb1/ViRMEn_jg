function vr = startITI_CA_Rig1(vr)

vr.itiStartTime = tic;
vr.inITI = 1;

vr.worlds{vr.currentWorld}.surface.visible(:) = 0; % make surface of world invisible
vr.worlds{vr.currentWorld}.backgroundColor = [0.59 0.59 0.59]; % set ITI color to specific grey value

end
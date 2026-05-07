function code = linearTrack_none
% linearTrackNew   Code for the ViRMEn experiment linearTrackNew.
%   code = linearTrackNew   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


%% MAZE DESCRIPTION
% tAlternating_v2_phase03
% stem length fixed at 300
% tower distance fixed at 15
% two tower percentage at 100% unless percentage correct is below 50, in
% which case it reverts to single towers
% blackout delay period is minimum 0.1 second, drawn from hand-crafted
% discrete distribution

% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)

% wrap world 
for k = 1:length(vr.worlds)
nvert = size(vr.worlds{k}.surface.vertices,2);
xyzoffset = [0 400 0; 0 -400 0; 0 800 0]';
orig = vr.worlds{k};
for j = 1:size(xyzoffset,2)
offsetmat = repmat(xyzoffset(:,j),1,nvert);
vr.worlds{k}.surface.vertices =  [vr.worlds{k}.surface.vertices orig.surface.vertices+offsetmat];
vr.worlds{k}.surface.triangulation = [vr.worlds{k}.surface.triangulation orig.surface.triangulation+(nvert*j)];
vr.worlds{k}.surface.visible = [vr.worlds{k}.surface.visible orig.surface.visible];
vr.worlds{k}.surface.colors = [vr.worlds{k}.surface.colors orig.surface.colors];
end
end

% invert colors in world 2

vr.currentWorld = 3;
% vr.worlds{3}.surface.colors(1:3,:) = abs(1-vr.worlds{3}.surface.colors(1:3,:));

% for k = 1:length(vr.worlds)
% vr.worlds{k}.surface.colors(1,:) = 0;
% end



%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

vr.position(2) = mod(vr.position(2),400);
switch vr.keyPressed
            case 49
                % "1" key pressed: switch world to world 1
                vr.currentWorld = 1;
            case 50
                vr.currentWorld = 2;
            case 51
                vr.currentWorld = 3;
        end




% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
delete(instrfind);
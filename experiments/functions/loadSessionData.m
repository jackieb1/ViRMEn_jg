function [vr] = loadSessionData(vr)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

dlgtitle = 'Input Playback Session';
dims = [1 35];
prompt = {'Mouse ID','Date (YYMMDD)', 'Session', 'Start time (s)', 'End time (s)', 'Directory'};
definput = {'', '', 'session_1', '0', 'end', 'Z:\HarveyLab\Tier1\Jonathan\Behavior_Imaging_Data\Virmen'};
dlgInfo = inputdlg(prompt, dlgtitle, dims, definput);
vr.playbackMouseNum = dlgInfo{1};
vr.playbackDate = dlgInfo{2};
vr.playbackSession = dlgInfo{3};
vr.parentDir = dlgInfo{6};
vr.playbackFullPath = fullfile(vr.parentDir, vr.playbackMouseNum, vr.playbackDate, vr.playbackSession, 'sessionData.mat'); %insert path here
temp = load(vr.playbackFullPath, 'sessionData');
dt = mean(temp.sessionData(10, :));
disp(['Mean dt:' num2str(dt)]);
vr.start_idx = int64(str2double(dlgInfo(4))*60/dt);
vr.end_idx = int64(str2double(dlgInfo(5))*60/dt);
vr.behavData = temp.sessionData(:, vr.start_idx:vr.end_idx);
end


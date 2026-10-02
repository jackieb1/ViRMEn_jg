function vr = saveTrialData(vr, trialInfo)
% trialInfo (optional) - struct of per-trial task info, saved in the trial file
%                        alongside behavData (e.g. the unexpected-reward task).

nIters = vr.trialIterations;
behavData = vr.behaviorData(:,1:nIters);
trialName = sprintf('Trial#%03.0f',vr.numTrials);
trialFileName = fullfile(vr.fullPath,trialName);
if nargin >= 2 && ~isempty(trialInfo)
    save(trialFileName,'behavData','trialInfo');
else
    save(trialFileName,'behavData');
end

% Reset trial iteration counter and behavior data matrix
vr.trialIterations = 0;
vr.behaviorData = nan(11,1e4);

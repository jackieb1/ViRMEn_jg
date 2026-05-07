function [vr,sessionData] = collectTrialData_fromDir(directory)

files = dir(fullfile(directory, 'Trial*.mat'));
sessionData = [];
for nTrial = 1:length(files)
    file = files(nTrial);
    trialFileName = fullfile(file.folder, file.name);
    load(trialFileName),
    behavData(end+1,:) = nTrial;
    sessionData = cat(2, sessionData, behavData);
    trialData(nTrial) = 1;
end
 
fprintf('\nConcatenated %03.0f Trials\n', sum(trialData)),
sessionDataName = fullfile(directory, 'sessionData');
save(sessionDataName, 'sessionData'),
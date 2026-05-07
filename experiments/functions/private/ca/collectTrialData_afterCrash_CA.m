function collectTrialData_afterCrash(fullPath, numTrials)

if numTrials>1
    sessionData = [];
    for nTrial = 1:numTrials
        try
            trialName = sprintf('Trial#%03.0f',nTrial);
            trialFileName = fullfile(fullPath,trialName);
            load(trialFileName),
            behavData(end+1,:) = nTrial;
            sessionData = cat(2,sessionData,behavData);
            trialData(nTrial) = 1;
        end
    end
end
    fprintf('\n Concatenated Data for %03.0f Trials \n',sum(trialData)),
    sessionDataName = fullfile(fullPath,'sessionData');
    %experData = exper;
    save(sessionDataName,'sessionData')
    
end